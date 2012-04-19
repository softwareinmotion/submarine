ssh_options[:user] = "administrator"
set :rails_env, 'production-ext'
set :domain, "swim-ext003.swim.dmz"
set :product_variant, 'presentation'
role :web,  domain 
role :app,  domain 
role :db, domain, :primary => true

