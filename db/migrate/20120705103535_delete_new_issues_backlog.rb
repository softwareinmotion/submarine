class DeleteNewIssuesBacklog < ActiveRecord::Migration
  def up
    if Backlog.find_by_name('new_issues')
  	  Backlog.find_by_name('new_issues').delete
    end
  end

  def down
  	Backlog.create(:name => 'new_issues', :locked => false)
  end
end
