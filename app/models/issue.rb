class Issue < ActiveRecord::Base
  belongs_to :project
  belongs_to :predecessor, :class_name => 'Issue', :foreign_key => :predecessor_id
  feature_active? :temp_lock_lists do
    belongs_to :backlog
  end

  # next item in the list
  has_one :descendant, :class_name => 'Issue', :foreign_key => :predecessor_id
  
  validates :name, :type, :project, :description, presence: true

  before_destroy :close_gap

  unless feature_active? :temp_lock_lists
    scope :in_backlog, where("(issues.sprint_flag is null or issues.sprint_flag = ?) and finished = ?", false, false)    
  end
  scope :in_sprint, where("issues.sprint_flag = ? and finished = ?", true, false)
  scope :finished, where("issues.finished = ?", true)

  if feature_active? :temp_lock_lists
    scope :first_in_list, where(predecessor_id: nil)
  else
    scope :first, where("predecessor_id is null")
  end 

  def self.children_type_names
    ['UserStory', 'Task', 'Bug']
  end

  def formatted_story_points
    if self.story_points
      self.story_points == 0.5 ? '0.5' : story_points.to_i.to_s
    else
      ''
    end
  end
  
  def update_lists backlog_list, sprint_backlog_list
    backlog_list.each_with_index do |id, i|
      Issue.find(id).update_attributes!(:predecessor_id => (i == 0 ? nil : backlog_list[i-1]), :sprint_flag => false)
    end
    if backlog_list.length > 0
      first_backlog_issue = Issue.find_by_id backlog_list.first
      first_backlog_issue.predecessor_id = nil
      first_backlog_issue.save
    end 
    
    sprint_backlog_list.each_with_index do |id, i|
      Issue.find(id).update_attributes!(:predecessor_id => (i == 0 ? nil : sprint_backlog_list[i-1]), :sprint_flag => true)
    end
    if sprint_backlog_list.length > 0
      first_sprint_backlog_issue = Issue.find_by_id sprint_backlog_list.first
      first_sprint_backlog_issue.predecessor_id = nil
      first_sprint_backlog_issue.save
    end
  end
  
  def finish
    self.close_gap
    self.reload
    if Issue.finished.size > 0
      first_finished = Issue.first.finished[0]
      first_finished.predecessor_id = self.id
      first_finished.save
    end
    
    self.predecessor_id = nil
    self.sprint_flag = false
    self.finished = true
    self.save!
  end
  
  def activate
    self.close_gap
    self.reload
    if feature_active? :temp_lock_lists
      backlog_size = Backlog.backlog.size
    else
      backlog_size = Issue.in_backlog.size
    end

    if backlog_size > 0
      if feature_active? :temp_lock_lists
        first = Backlog.backlog.first
      else
        first = Issue.first.in_backlog[0]
      end        
      first.predecessor_id = self.id
      first.save
    end
    
    self.predecessor_id = nil
    self.sprint_flag = false
    self.finished = false
    self.save!
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
