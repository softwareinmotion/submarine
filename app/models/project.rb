class Project < ActiveRecord::Base
  has_many :issues, :dependent => :destroy

  validates :name, :length => { :maximum => 50 }
  validates_presence_of :name
  mount_uploader :project_icon, ProjectIconUploader

  default_scope { order('name ASC') }
end
