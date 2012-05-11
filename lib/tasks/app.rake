require "fileutils"

namespace :submarine do
  task :ensure_development_environment => :environment do
    if Rails.env.production?
      raise "\nCan't do this in production, check environment.\n\n"
    end
  end
 
  desc "Reset database and populate it with example data."
  task :reset => %w[submarine:ensure_development_environment db:drop db:create db:migrate submarine:populate]
 
  desc "Reset database and populate it with example data for production environment test."
  task :prep_pres => %w[db:drop db:create db:migrate submarine:populate]
 
  desc "loads example data for all models to use in development"
  task :populate => :environment do
    prj_other = Project.create name: 'Sonstiges'
    prj_submarine = Project.create name: 'submarine'
    prj_fancy = Project.create name: 'Fancy'

    # backlog items
    task = Task.create name: 'UI-Styling', description: 'Entwerfen und umsetzen eines Stylings', project: prj_submarine, sprint_flag: false, finished: false
    bug = Bug.create name: 'Fehler beim Eintragen eines Strings als Buchpreis', description: 'Anlegen eines neuen Buchs: Wird in das Feld Preis ein String eingetragen, z. B. fancy, und auf Speichern geklickt, kommt man auf eine allgemeine Fehlerseite "Sorry, but something went wrong.".', story_points: 1, project: prj_fancy, sprint_flag: false, finished: false, predecessor: task
    Task.create name: 'UI-Styling', description: 'Entwerfen und umsetzen eines Stylings', project: prj_fancy, sprint_flag: false, finished: false, predecessor: bug

    # sprint items
    story = UserStory.create name: 'User Stories bearbeiten', description: 'Als Product Owner kann ich User Stories bearbeiten, damit ich diesen weitere Informationen wie bspw. die Story Points zuordnen kann.', story_points: 2, project: prj_submarine, sprint_flag: true, finished: false, predecessor: nil
    Task.create name: 'CI-Server', description: 'Suchen und installieren eines geeigneten CI-Servers', story_points: 5, project: prj_other, sprint_flag: true, finished: false, predecessor: story

    # finished items
    UserStory.create name: 'User Stories anlegen', description: 'Als Product Owner kann ich User Stories in das Backlog eintragen.', project: prj_submarine, story_points: 3, sprint_flag: false, finished: true
  end

  desc "populate example data for development purposes"
  task :populate_dev => :environment do
    ### create projects and tasks
    proj_n_backlogs = [["Sonstiges", Backlog.finished_backlog], ["submarine", Backlog.sprint_backlog], ["Fancy", Backlog.backlog]]

    proj_n_backlogs.each do |pair|
      proj = Project.create name: pair[0]
      last_task = nil

      # create issues for a project
      'a'.upto('d') do |iss_letter|
        task = Task.new(name: "Task_#{iss_letter}_#{pair[0]}", description: "do something for Task_#{iss_letter}_#{pair[0]}", project: proj, story_points: 1)
        task.predecessor = last_task if last_task
        last_task = task
        pair[1].issues << task
      end

      proj
    end

    ### overwrite configuration
    Configurable.create name: "max_lock_time", value: 8
    Configurable.create name: "max_lock_time_delay", value: 1
  end

  desc "Includes feature dependent migration files in db:migrate task"
  task :feature_migrate => %w[submarine:cp_feature_migrations db:migrate submarine:rm_feature_migrations]

  desc "Copies feature dependent migration files to the db/migrate directory"
  task :cp_feature_migrations do
    src_path = "#{Rails.root}/db/feature_migrate/"
    Dir.foreach(src_path) do |file_name|
      if file_name =~ /.+\.rb$/
        FileUtils.copy (src_path + file_name), "#{Rails.root}/db/migrate"
        puts "Copied #{file_name} to db/migrate"
      end
    end
  end

  desc "Removes feature dependent migration files from the db/migrate directory"
  task :rm_feature_migrations do
    migrate_path = "#{Rails.root}/db/migrate/"
    feature_migrate_path = "#{Rails.root}/db/feature_migrate/"

    Dir.foreach(feature_migrate_path) do |file_name|
      if file_name =~ /.+\.rb$/
        FileUtils.rm(migrate_path + file_name)
        puts "Removed #{file_name} from db/migrate"
      end
    end
  end

  task :populate_dev => %w[submarine:ensure_development_environment submarine:populate_simple_data]
  task :populate_simple_data => :environment do

  end
end
