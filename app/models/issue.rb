class Issue < ActiveRecord::Base
  belongs_to :project
  belongs_to :predecessor, :class_name => 'Issue', :foreign_key => :predecessor_id
  belongs_to :backlog

  # next item in the list
  has_one :descendant, :class_name => 'Issue', :foreign_key => :predecessor_id
  
  validates :name, :type, :project, :description, presence: true

  before_destroy :close_gap

  scope :first_in_list, where(predecessor_id: nil)
  scope :last_in_list, lambda { find_by_sql("select * from issues a where not exists (select * from issues b where b.predecessor_id = a.id)") }

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
    self.close_gap
    self.reload
    if Backlog.finished_backlog.issues.count > 0
      first_finished = Backlog.finished_backlog.first_issue
      if first_finished
        first_finished.predecessor_id = self.id
        first_finished.save
      end
    end

    self.predecessor_id = nil
    Backlog.finished_backlog.issues << self

    self.save!
  end

  def activate
    self.push_to_backlog Backlog.backlog
  end

  def push_to_backlog backlog
    close_gap
    self.reload

    unless backlog.issues.empty?
      backlog.first_issue.update_attributes predecessor_id: id
    end
    backlog.issues << self
    self.predecessor_id = nil
    self.save
  end

  def finished?
    backlog == Backlog.finished_backlog
  end

  def in_sprint?
    backlog == Backlog.sprint_backlog
  end
  
  def close_gap
    descendant = self.descendant
    if descendant
      descendant.predecessor_id = self.predecessor_id
      descendant.save!
    end
  end

  def move_to(backlog, options={})
    transaction do
      #remove issue from linked list
      #by connecting predecessor and descendant
      if self.descendant
        descendant = self.descendant
        self.descendant = nil
        descendant.predecessor = self.predecessor
        descendant.save_with_lock options[:lock_version]
      end
      self.predecessor = nil
      self.backlog = nil
      self.save_with_lock options[:lock_version]
  
      #insert issue into linked list
      #by setting new predecessor and his descendant
      if options.has_key? :new_predecessor
        new_predecessor = options[:new_predecessor]
        new_predecessor.reload
        new_descendant = new_predecessor.descendant
        if new_descendant && new_descendant != self
          new_descendant.predecessor = self
          new_descendant.save_with_lock options[:lock_version]
        end
        self.predecessor = new_predecessor
      else
        self.predecessor = nil
  
        new_descendant = Issue.where("backlog_id = :backlog_id AND predecessor_id IS NULL AND id != :issue_id", backlog_id: backlog.id, issue_id: self.id ).first
        if new_descendant
          new_descendant.predecessor = self
          new_descendant.save_with_lock options[:lock_version]
        end
      end
      if self.backlog != backlog
        self.backlog = backlog
      end
        self.save_with_lock options[:lock_version]
    end
  end

  def save_with_lock(lock_version)
    self.lock_version = lock_version[self.id.to_s]
    self.save!
    lock_version[self.id.to_s] = self.lock_version
  end
end
