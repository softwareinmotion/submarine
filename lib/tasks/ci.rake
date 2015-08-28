if Rails.env == 'ci'
  require 'ci/reporter/rake/rspec'
  require 'rspec/core/rake_task'

  RSpec::Core::RakeTask.new(:rspec)

  task :rspec => 'ci:setup:rspec'
end
