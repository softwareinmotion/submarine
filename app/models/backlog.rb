class Backlog < ActiveRecord::Base
  has_many :issues
end
