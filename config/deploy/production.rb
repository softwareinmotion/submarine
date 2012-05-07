ssh_options[:user] = "railsprod"
set :rails_env, 'production'
set :domain, 'submarine'
set :product_variant, 'swim'
role :web,  domain 
role :app,  domain 
role :db, domain, :primary => true
set :deploy_to, "/var/lib/#{application}"

