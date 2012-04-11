ssh_options[:user] = "administrator"
set :rails_env, 'production'
set :domain, "ent"
role :web,  domain 
role :app,  domain 
role :db, "production-" + domain, :primary => true
