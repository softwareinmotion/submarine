require 'capistrano/ext/multistage'
require 'bundler/capistrano'

set :stages, %w(production ent transformers admin ext seminar azubi)
set :default_stage, "ent"

default_run_options[:pty] = true

set :application, 'submarine'
set :scm, :git
set :repository,  "ssh://entadmin@192.168.202.4/home/Projects/#{application}.git"

set :use_sudo, false
set :rake,      "bundle exec rake"


namespace :deploy do
  task :start, :roles => [:web, :app] do 
    run "cd #{deploy_to}/current && PRODUCT_VARIANT=#{product_variant} nohup bundle exec thin -C thin/#{stage}_config.yml -R thin/config.ru start" 
  end
  task :stop, :roles => [:web, :app] do 
    run "cd #{deploy_to}/current && bundle exec thin -C thin/#{stage}_config.yml stop"
  end
  task :restart, :roles => [:web, :app], :except => { :no_release => true } do
    deploy.stop
    deploy.start
  end
  task :seed, :roles => [:web, :app] do
    run "cd #{deploy_to}/current && bundle exec rake db:seed RAILS_ENV=#{rails_env}"
  end
end
after "deploy:update_code" do
  run "rm -rf  #{release_path}/public/uploads"
  run "mkdir -p  #{shared_path}/uploads"
  run "ln -nfs  #{shared_path}/uploads  #{release_path}/public/uploads"
end