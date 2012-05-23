# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

['backlog', 'sprint_backlog', 'finished_backlog', 'new_issues'].each do |bl_name|
  unless Backlog.find_by_name bl_name
    Backlog.create! name: bl_name, locked: false
  end
end
