class AddExaminedAtAndPlannedAtAndDoneAtToIssues < ActiveRecord::Migration
  def change
    add_column :issues, :examined_at, :datetime
    add_column :issues, :planned_at, :datetime
    add_column :issues, :done_at, :datetime
  end
end
