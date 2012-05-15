ssh_options[:user] = "administrator"
set :rails_env, 'production-ent'
set :domain, "ent"
set :product_variant, 'lock_lists'
set :deploy_to, "/var/lib/#{application}"
set :stage, "ent_lock"
role :web,  domain 
role :app,  domain 
role :db, domain, :primary => true
