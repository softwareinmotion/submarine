class AddFinishedFlagForIssue < ActiveRecord::Migration
  def up
    add_column :issues, :finished, :boolean, :default => false
  end

  def down
    remove_column :issues, :finished
  end
end
