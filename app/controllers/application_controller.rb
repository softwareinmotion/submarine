class ApplicationController < ActionController::Base
  before_filter :count_backlogs
  protect_from_forgery

  def count_backlogs
    @backlog_count = Backlog.backlog.issues.count
    @sprintbacklog_count = Backlog.sprint_backlog.issues.count
    @finished_issues_count = Backlog.finished_backlog.issues.count

    feature_active? :temp_changes_for_iso do
      @new_issues_list_count = Backlog.new_issues_list.issues.count
    end
  end
end
