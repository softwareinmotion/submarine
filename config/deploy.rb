set :scm, :git

set :format, :pretty

set :log_level, :debug

set :repo_url,  "ssh://entadmin@192.168.202.4/home/Projects/submarine.git"

set :deploy_to, -> { "/var/lib/submarine_#{fetch(:stage)}" }
set :rails_env, 'production'

set :linked_files, %w{config/database.yml}
set :linked_dirs, %w{public/uploads}

set :app_key, -> {Pathname("#{fetch(:deploy_to)}").basename}

set :default_env, -> { { path: "#{fetch(:deploy_to)}/shared/bin:$PATH" } }

set :keep_releases, 5

set :bundle_without, 'development test'

server 'SLAP03.swim.de', user: 'deploy', roles: %w{web app db}

# configure start / stop / restart tasks for the app
namespace :deploy do
  desc 'start the app servers'
  task :start do
    on roles(:app) do
      execute(:thin, "-C #{fetch(:deploy_to)}/shared/config/thin_config.yml start")
    end
  end

  desc 'stop the app servers'
  task :stop do
    on roles(:app) do
      execute(:thin, "-C #{fetch(:deploy_to)}/shared/config/thin_config.yml stop")
    end
  end

  desc 'restart the app servers'
  task :restart do
    on roles(:app) do
      execute(:thin, "-C #{fetch(:deploy_to)}/shared/config/thin_config.yml restart")
    end
  end

  task :unmonitor_god_process do
    on roles(:app) do
      execute("sudo god unmonitor #{fetch(:app_key)}_group")
    end
  end

  task :monitor_god_process_and_restart do
    on roles(:app) do
      execute("sudo god monitor #{fetch(:app_key)}_group")
      execute("sudo god restart #{fetch(:app_key)}_group")
    end
  end

  after :finishing, 'deploy:cleanup'
end