class SetBacklogForIssuesToNewIssuesList < ActiveRecord::Migration
  def change
    feature_active? :temp_changes_for_iso do
      Issue.where(backlog: Backlog.backlog).each do |issue|
        issue.move_to(Backlog.new_issues_list)
      end
    end
  end
end
