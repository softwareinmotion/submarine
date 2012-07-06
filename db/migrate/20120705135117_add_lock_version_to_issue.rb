class AddLockVersionToIssue < ActiveRecord::Migration
  def change
  	add_column :issues, :lock_version, :integer
  end
end
