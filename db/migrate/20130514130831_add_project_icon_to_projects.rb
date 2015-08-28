class AddProjectIconToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :project_icon, :string
  end
end
