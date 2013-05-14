ssh_options[:user] = "administrator"
set :rails_env, 'production-ent'
set :domain, "ent"
set :product_variant, 'presentation'
set :deploy_to, "/var/lib/#{application}"
set :stage, "ent"
role :web,  domain 
role :app,  domain 
role :db, domain, :primary => true
