class RemoveLockingColumns < ActiveRecord::Migration
  def up
  	remove_column :backlogs, :locked
  	remove_column :backlogs, :locked_session_id
  end

  def down
  	add_column :backlogs, :locked, :boolean, :default => false
  	add_column :backlogs, :locked_session_id, :boolean
  end
end
