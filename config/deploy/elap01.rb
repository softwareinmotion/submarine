ssh_options[:user] = "administrator"
set :rails_env, 'elte04'
set :domain, 'ELTE04.swim.de'
set :product_variant, 'swim'
set :subdomain, 'azubi_'
set :stage, "elte04"
set :deploy_to, "/var/lib/#{subdomain}#{application}"
role :web,  domain
role :app,  domain
role :db, domain, :primary => true

