require 'helper/lock_version_helper'

class Issue < ActiveRecord::Base
  belongs_to :project
  belongs_to :predecessor, :class_name => 'Issue', :foreign_key => :predecessor_id
  belongs_to :backlog
  # next item in the list
  has_one :descendant, :class_name => 'Issue', :foreign_key => :predecessor_id

  mount_uploader :file_attachment, FileAttachmentUploader

  validates :name, :type, :project, :description, presence: true

  before_destroy :close_gap
  before_save :set_lock
  after_save :update_lock

  scope :first_in_list, -> { where(predecessor_id: nil) }
  scope :last_in_list, -> { find_by_sql("select * from issues a where not exists (select * from issues b where b.predecessor_id = a.id)") }

  def self.children_type_names
    ['UserStory', 'Task', 'Bug', 'Document']
  end

  def formatted_story_points
    if self.story_points
      self.story_points == 0.5 ? '0.5' : story_points.to_i.to_s
    else
      ''
    end
  end

  def finish
    move_to Backlog.finished_backlog
  end

  def activate
    move_to Backlog.backlog
  end

  def finished?
    backlog == Backlog.finished_backlog
  end

  def in_sprint?
    backlog == Backlog.sprint_backlog
  end

  feature_active? :temp_changes_for_iso do
    def in_backlog?
      backlog == Backlog.backlog
    end
  end

  def close_gap
    descendant = self.descendant
    if descendant
      descendant.predecessor_id = self.predecessor_id
      descendant.save!
    end
  end

  def move_to(backlog, options={}) #!ref!
    transaction do
      #remove issue from linked list
      #by connecting predecessor and descendant
      if self.descendant
        descendant = self.descendant
        self.descendant = nil
        descendant.predecessor = self.predecessor
        descendant.save!
      end
      self.predecessor = nil
      self.backlog = nil
      self.save!

      #insert issue into linked list
      #by setting new predecessor and his descendant
      if options.has_key? :new_predecessor
        new_predecessor = options[:new_predecessor]
        new_predecessor.reload

        raise "Backlog of predecessor does not match the passed backlog" if new_predecessor.backlog != backlog

        new_descendant = new_predecessor.descendant
        if new_descendant && new_descendant != self
          new_descendant.predecessor = self
          new_descendant.save!
        end
        self.predecessor = new_predecessor
      else
        self.predecessor = nil

        new_descendant = Issue.where("backlog_id = :backlog_id AND predecessor_id IS NULL AND id != :issue_id", backlog_id: backlog.id, issue_id: self.id ).first
        if new_descendant
          new_descendant.predecessor = self
          new_descendant.save!
        end
      end

      self.backlog = backlog if self.backlog != backlog
      self.save!
    end
  end

  def set_lock
    if LockVersionHelper::lock_version == nil
      return
    end

    self.lock_version = LockVersionHelper::lock_version[self.id.to_s]
  end

  def update_lock
    if LockVersionHelper::lock_version == nil
      return
    end

    LockVersionHelper::lock_version[self.id.to_s] = self.lock_version
  end
end