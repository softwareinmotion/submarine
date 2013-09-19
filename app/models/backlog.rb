class Backlog < ActiveRecord::Base
  has_many :issues

  def self.backlog
    Backlog.where(name: 'backlog').first
  end

  def self.sprint_backlog
    Backlog.where(name: 'sprint_backlog').first
  end

  def self.finished_backlog
    Backlog.where(name: 'finished_backlog').first
  end

  def first_issue
    self.issues.first_in_list.first
  end

  def last_issue
    self.issues.last_in_list.first
  end

  def update_with_list list
    if list and list.length > 0
      list.each_with_index do |id, i|
        Issue.find(id).update_attributes!(:predecessor_id => (i == 0 ? nil : list[i-1]), :backlog => self)
      end
      first_backlog_issue = Issue.find_by_id list.first
      first_backlog_issue.predecessor_id = nil
      first_backlog_issue.save
    end
  end

end
