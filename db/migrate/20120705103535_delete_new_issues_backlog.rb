class DeleteNewIssuesBacklog < ActiveRecord::Migration
  def up
  	Backlog.find_by_name('new_issues').delete
  end

  def down
  	Backlog.create(:name => 'new_issues', :locked => false)
  end
end
