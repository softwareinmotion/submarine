set :rvm_ruby_string, '1.9.3-p385@submarine'
set :rvm_type, :system  # Copy the exact line. I really mean :user here

require 'rvm/capistrano'
# bundler bootstrap
require 'bundler/capistrano'

load 'deploy' if respond_to?(:namespace) # cap2 differentiator

# Uncomment if you are using Rails' asset pipeline
load 'deploy/assets'

Dir['vendor/gems/*/recipes/*.rb','vendor/plugins/*/recipes/*.rb'].each { |plugin| load(plugin) }

load 'config/deploy' # remove this line to skip loading any of the default tasks
