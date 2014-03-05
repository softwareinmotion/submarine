set :scm, :git

set :format, :pretty

set :log_level, :debug

set :repo_url,  "ssh://entadmin@192.168.202.4/home/Projects/submarine.git"
set :keep_releases, 5

set :deploy_to, -> { "/var/lib/submarine_#{fetch(:stage)}" }
set :rails_env, 'production'

set :linked_files, %w{config/database.yml}
set :linked_dirs, %w{public/uploads}

set :app_key, -> {Pathname("#{fetch(:deploy_to)}").basename}

set :default_env, -> { { path: "#{fetch(:deploy_to)}/shared/bin:$PATH" } }

set :bundle_without, 'development test'

server 'SLAP03.swim.de', user: 'deploy', roles: %w{web app db}