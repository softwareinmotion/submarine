ssh_options[:user] = "railsprod"
set :rails_env, 'production-ext'
set :domain, "10.10.50.3"
set :product_variant, 'presentation'
set :deploy_via, :copy
set :copy_strategy, :export

set :deploy_to, "/var/lib/#{application}"
set :stage, "ext"
role :web,  domain 
role :app,  domain 
role :db, domain, :primary => true

