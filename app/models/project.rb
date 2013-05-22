class Project < ActiveRecord::Base
  has_many :issues

  validates_presence_of :name
  attr_accessible :name, :project_icon, :remove_project_icon
  mount_uploader :project_icon, ProjectIconUploader
end
