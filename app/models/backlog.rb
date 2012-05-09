class Backlog < ActiveRecord::Base
  has_many :issues

  def self.backlog
    Backlog.where(name: 'backlog').first
  end

  def self.backlog_with_lock
    Backlog.where(name: 'backlog').lock(true).first
  end

  def self.sprint_backlog
    Backlog.where(name: 'sprint_backlog').first
  end

  def self.sprint_backlog_with_lock
    Backlog.where(name: 'sprint_backlog').lock(true).first
  end

  def self.finished_backlog
    Backlog.where(name: 'finished_backlog').first
  end

  def self.new_issues
    Backlog.where(name: 'new_issues').first
  end

  def first_issue
    self.issues.first_in_list.first
  end

  def update_with_list list
    if list.length > 0
      list.each_with_index do |id, i|
        Issue.find(id).update_attributes!(:predecessor_id => (i == 0 ? nil : list[i-1]), :backlog => self)
      end
      first_backlog_issue = Issue.find_by_id list.first
      first_backlog_issue.predecessor_id = nil
      first_backlog_issue.save
    end 
  end

  def locked_by_session? session_id
    self.locked and self.locked_session_id == session_id
  end

  def locked_by_another_session? session_id
    self.locked and not self.locked_session_id == session_id
  end

  def lock_for_session session_id
    self.locked = true
    self.locked_session_id = session_id
  end

  def unlock
    self.locked = false
    self.locked_session_id = nil
  end
end
