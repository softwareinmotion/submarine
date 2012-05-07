require 'capistrano/ext/multistage'

set :stages, %w(production ent transformers)
set :default_stage, "ent"

default_run_options[:pty] = true

set :application, 'submarine'
set :scm, :git
set :repository,  "ssh://entadmin@192.168.202.4/home/Projects/#{application}.git"

set :use_sudo, false
set :rake,      "bundle exec rake"
set :deploy_to, "/var/lib/#{application}"

namespace :deploy do
  task :start, :roles => [:web, :app] do 
    run "cd #{deploy_to}/current && PRODUCT_VARIANT=#{product_variant} nohup bundle exec thin -C thin/#{domain}_config.yml -R thin/config.ru start" 
  end
  task :stop, :roles => [:web, :app] do 
    run "cd #{deploy_to}/current && bundle exec thin -C thin/#{domain}_config.yml stop"
  end
  task :restart, :roles => [:web, :app], :except => { :no_release => true } do
    deploy.stop
    deploy.start
  end
end
