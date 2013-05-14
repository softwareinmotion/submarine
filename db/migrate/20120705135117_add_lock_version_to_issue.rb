class AddLockVersionToIssue < ActiveRecord::Migration
  def up
  	add_column :issues, :lock_version, :integer, :default => 0
  end

  def down
  	remove_column :issues, :lock_version
  end
end
