source 'http://rubygems.org'

gem 'rails', '3.2.2'

# Bundle edge Rails instead:
# gem 'rails',     :git => 'git://github.com/rails/rails.git'

gem 'sqlite3'
gem 'thin'
gem 'pg' # needs native extensions: sudo aptitude install libpq-dev
gem 'linecache19', :git => 'https://github.com/mark-moseley/linecache.git' 
gem 'ruby_flipper'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'uglifier', '>= 1.0.3'
  gem 'therubyracer'
  gem 'execjs'
end

gem 'jquery-rails'

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# Use unicorn as the web server
# gem 'unicorn'

# Deploy with Capistrano
gem 'capistrano'


group :test, :development do
  gem 'rspec-rails', '~> 2.6'
  gem 'factory_girl'

  # To use debugger
  gem 'ruby-debug-base19x', '0.11.30.pre10'
  gem 'ruby-debug19', :require => 'ruby-debug'
  gem 'awesome_print'
  gem 'pry'
  # Pretty printed test output
  gem 'turn', '0.8.2', :require => false
  
  gem 'yaml_db'
end

group :production do
  gem 'pg'
end
