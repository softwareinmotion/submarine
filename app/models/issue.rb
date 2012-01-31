class Issue < ActiveRecord::Base
  belongs_to :project
  
  validates_presence_of :name, :type

  def self.children_type_names
    ['Bug', 'Task', 'UserStory']
  end

  def formatted_story_points
    self.story_points.to_i == self.story_points ? story_points.to_i.to_s : '1/2'
  end
end
