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
    update_attributes(examined_at: DateTime.now, finished_at: nil, done_at: nil, planned_at: nil, ready_to_finish: false)
    move_to Backlog.backlog
  end

  def finished?
    backlog == Backlog.finished_backlog
  end

  def in_sprint?
    backlog == Backlog.sprint_backlog
  end

  def in_new_issue_list?
    backlog == Backlog.new_issues_list
  end

  def in_backlog?
    backlog == Backlog.backlog
  end

  def done!
    update_attributes(ready_to_finish: true, done_at: DateTime.now)
  end

  def doing!
    update_attributes(planned_at: DateTime.now, ready_to_finish: false, done_at: nil)
  end

  def done?
    self.ready_to_finish == true
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

      log_move_changes(backlog)

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

  private

  def log_move_changes new_list_type
    case new_list_type

    when Backlog.backlog
      if self.in_new_issue_list? #comes from new_issues_list
        update_attributes(examined_at: DateTime.now)
      elsif self.in_sprint? #comes from sprint_backlog
        update_attributes(examined_at: DateTime.now, planned_at: nil)
      end
    when Backlog.new_issues_list
      update_attributes(examined_at: nil)
    when Backlog.sprint_backlog
      update_attributes(planned_at: DateTime.now)
    end
  end
end