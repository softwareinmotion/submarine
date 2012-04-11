ssh_options[:user] = "administrator"
set :domain, "ent"
role :web,  domain 
role :app,  domain 
role :db, domain, :primary => true
