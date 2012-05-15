ssh_options[:user] = "railsprod"
set :rails_env, 'production-transformers'
set :domain, 'submarine-transformers'
set :product_variant, 'swim'
set :subdomain, 'transformers_'
set :stage, "submarine-transformers"
set :deploy_to, "/var/lib/#{subdomain}#{application}"
role :web,  domain 
role :app,  domain 
role :db, domain, :primary => true

