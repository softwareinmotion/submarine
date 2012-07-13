class AddDefaultLockVersionToIssues < ActiveRecord::Migration
  def up
  	Issue.update_all lock_version: 0
  end

  def down
  end
end
