ssh_options[:user] = "administrator"
set :rails_env, 'production-ent'
set :domain, "ent"
set :product_variant, 'presentation'
role :web,  domain 
role :app,  domain 
role :db, domain, :primary => true
