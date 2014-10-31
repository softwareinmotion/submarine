class SetDefaultValueToNullFromFinishedAtForIssues < ActiveRecord::Migration
  def change
    change_column :issues, :finished_at, :datetime, :default => nil
  end
end
