ssh_options[:user] = "administrator"
set :rails_env, 'production'
set :application, "submarine"
set :deploy_to, "/var/lib/submarine"
set :use_sudo, false
default_run_options[:pty] = true
set :rake,      "bundle exec rake"

set :scm, :git
set :repository,  "ssh://entadmin@192.168.202.4/home/Projects/submarine.git"


role :web, "ent"                          # Your HTTP server, Apache/etc
role :app, "ent"                          # This may be the same as your `Web` server
role :db,  "ent", :primary => true # This is where Rails migrations will run

namespace :deploy do
  task :start, :roles => [:web, :app] do 
    run "cd #{deploy_to}/current && nohup bundle exec thin -C thin/production_config.yml -R thin/config.ru start" 
  end
  task :stop, :roles => [:web, :app] do 
    run "cd #{deploy_to}/current && nohup bundle exec thin -C thin/production_config.yml -R thin/config.ru stop"
  end
#  task :restart, :roles => [:web, :app], :except => { :no_release => true } do
#    deploy.stop
#    deploy.start
#  end
end
