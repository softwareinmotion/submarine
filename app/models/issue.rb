class Issue < ActiveRecord::Base
  belongs_to :project
  belongs_to :predecessor, :class_name => 'Issue', :foreign_key => :predecessor_id
  # next item in the list
  has_one :descendant, :class_name => 'Issue', :foreign_key => :predecessor_id
  
  validates :name, :type, :project, :description, presence: true

  before_destroy :close_gap

  scope :in_backlog, where("issues.sprint_flag is null or issues.sprint_flag = ?", false)
  scope :in_sprint, where("issues.sprint_flag = ?", true)

  def self.children_type_names
    ['Bug', 'Task', 'UserStory']
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
  
  private
  
  
  def close_gap
    descendant = self.descendant
    if descendant
      descendant.predecessor_id = self.predecessor_id
      descendant.save!
    end
    self.predecessor_id = nil
  end
  
end
