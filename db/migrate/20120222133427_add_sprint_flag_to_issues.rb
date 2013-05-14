class AddSprintFlagToIssues < ActiveRecord::Migration
  def change
    add_column :issues, :sprint_flag, :boolean
  end
end
