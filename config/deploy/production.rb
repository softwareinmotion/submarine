ssh_options[:user] = "railsprod"
set :domain, 'submarine'
role :web,  domain 
role :app,  domain 
role :db, domain, :primary => true
