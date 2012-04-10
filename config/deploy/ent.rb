ssh_options[:user] = "administrator"
set :domain, "ent"
set :branch, 'multistage'
role :web,  domain 
role :app,  domain 
role :db, domain, :primary => true
