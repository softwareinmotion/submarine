ssh_options[:user] = "railsprod"
set :rails_env, 'production-transformers'
set :domain, 'transformers.submarine.swim.de'
set :product_variant, 'swim'
set :subdomain, 'transformers_'
set :deploy_to, "/var/lib/#{subdomain}#{application}"
role :web,  domain 
role :app,  domain 
role :db, domain, :primary => true

