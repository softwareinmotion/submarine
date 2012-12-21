ssh_options[:user] = "administrator"
set :rails_env, 'admin_submarine'
set :domain, 'ent'
set :product_variant, 'swim'
set :subdomain, 'admin_'
set :stage, "admin"
set :deploy_to, "/var/lib/#{subdomain}#{application}"
role :web,  domain 
role :app,  domain 
role :db, domain, :primary => true

