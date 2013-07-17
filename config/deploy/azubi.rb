ssh_options[:user] = "railsprod"
set :rails_env, 'azubi_submarine'
set :domain, 'submarine'
set :product_variant, 'swim'
set :subdomain, 'azubi_'
set :stage, "azubi"
set :deploy_to, "/var/lib/#{subdomain}#{application}"
role :web,  domain 
role :app,  domain 
role :db, domain, :primary => true

