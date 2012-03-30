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
end