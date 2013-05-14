class AddsTheListOrderIssuesAlreadyInTheDatabase < ActiveRecord::Migration
  def up
    issues = Issue.all
    issues[0].update_attributes(:predecessor_id => nil) if issues[0]
    for i in 1...issues.length
      issues[i].update_attributes(:predecessor_id => issues[i-1].id)
    end
  end

  def down
    Issue.all.each{|i| i.update_attributes(:predecessor_id => nil)}
  end
end
