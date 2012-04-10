ssh_options[:user] = "railsprod"
set :domain, 'submarine'
set :deploy_to, "/var/lib/#{application}"
role :web,  domain 
role :app,  domain 
role :db, domain, :primary => true
