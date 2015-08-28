class AddNewIssuesBacklog < ActiveRecord::Migration
  def change
    Backlog.create! name: "new_issues"
  end
end
