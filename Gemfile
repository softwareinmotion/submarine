source 'http://rubygems.org'

gem 'rails', '3.2.12'

# Bundle edge Rails instead:
# gem 'rails',     :git => 'git://github.com/rails/rails.git'

gem 'sqlite3', '~> 1.3.7'
gem 'thin'
gem 'pg' # needs native extensions: sudo aptitude install libpq-dev
gem 'ruby_flipper'
gem 'simple-navigation'
gem 'carrierwave-activerecord', :git => 'git://github.com/richardkmichael/carrierwave-activerecord.git'
gem "mini_magick"

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'uglifier', '>= 1.0.3'
  gem 'therubyracer', "~> 0.12.0"
  gem 'jquery-rails', "~> 2.2.1"
  gem "jquery-ui-rails", "~> 4.0.1"
  gem 'execjs'
  gem 'compass-rails'
end

gem 'slim-rails'

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# Use unicorn as the web server
# gem 'unicorn'

# Deploy with Capistrano
gem 'capistrano'
gem 'rvm-capistrano'
gem 'capistrano-ext'

group :test, :development do
  gem 'rspec-rails'
  gem "factory_girl_rails"
  gem "database_cleaner"
  gem 'guard-rspec'
  gem 'guard-spork'
  gem 'guard-livereload'
  gem 'spork'
  gem 'watchr'
  gem 'debugger'
  gem 'awesome_print'
  # Pretty printed test output
  gem 'turn', '0.8.2', :require => false

  gem 'yaml_db'
end

group :production do
  gem 'pg'
end
