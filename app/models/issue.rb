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
    self.push_to_backlog Backlog.new_issues
  end

  def push_to_backlog backlog
    close_gap
    reload

    unless backlog.issues.empty?
      backlog.first_issue.update_attributes predecessor_id: id
    end
    backlog.issues << self
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
    self.predecessor_id = nil
  end
end
