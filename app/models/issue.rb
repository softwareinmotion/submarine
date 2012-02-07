class Issue < ActiveRecord::Base
  belongs_to :project
  belongs_to :predecessor, :class_name => 'Issue', :foreign_key => :predecessor_id
  has_one :descendant, :class_name => 'Issue', :foreign_key => :predecessor_id
  
  validates_presence_of :name, :type

  after_create :set_predecessor

  def self.children_type_names
    ['Bug', 'Task', 'UserStory']
  end

  def formatted_story_points
    if self.story_points
      self.story_points == 0.5 ? '1/2' : story_points.to_i.to_s
    else
      ''
    end
  end

  def pin_after issue_id
    old_descendant = Issue.find_by_predecessor_id self.id
    if old_descendant 
      old_descendant.predecessor_id = self.predecessor_id
      old_descendant.save
    end

    new_descendant = Issue.find_by_predecessor_id issue_id
    self.predecessor_id = issue_id
    self.save

    if new_descendant
      new_descendant.predecessor_id = self.id
      new_descendant.save
    end
  end
  
  private
  
  def set_predecessor
    list_head = Issue.where("id <> ?", self.id).find_by_predecessor_id nil
    if list_head
      list_head.predecessor_id = self.id
      list_head.save!
    end
  end
end
