class SetFinishedAtForIssuesToNil < ActiveRecord::Migration
  def change
    Issue.where(backlog: Backlog.backlog).each do |issue|
      issue.update(finished_at: nil)
    end
  end
end
