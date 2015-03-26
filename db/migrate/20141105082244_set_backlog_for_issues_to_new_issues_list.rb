class SetBacklogForIssuesToNewIssuesList < ActiveRecord::Migration
  def change
    feature_active? :temp_changes_for_iso do
      Issue.where(backlog: Backlog.backlog).each do |issue|
        issue.backlog = Backlog.new_issues_list
        issue.examined_at = nil
        issue.save!
      end
    end
  end
end
