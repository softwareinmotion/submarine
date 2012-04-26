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
end
