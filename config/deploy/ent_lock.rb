ssh_options[:user] = "administrator"
set :rails_env, 'production-ent'
set :domain, "ent_lock"
set :product_variant, 'lock_lists'
set :deploy_to, "/var/lib/#{application}"
role :web,  domain 
role :app,  domain 
role :db, domain, :primary => true
