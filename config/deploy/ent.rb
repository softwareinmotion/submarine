ssh_options[:user] = "administrator"
set :domain, "ent"
set :branch, 'multistage'
set :deploy_to, "/var/lib/#{application}"
role :web,  domain 
role :app,  domain 
role :db, domain, :primary => true
