ssh_options[:user] = "railsprod"
set :rails_env, 'seminar_submarine'
set :domain, 'submarine'
set :product_variant, 'swim'
set :subdomain, 'seminar_'
set :stage, "seminar"
set :deploy_to, "/var/lib/#{subdomain}#{application}"
role :web,  domain 
role :app,  domain 
role :db, domain, :primary => true

