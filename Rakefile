require File.join(File.dirname(__FILE__), 'lib/voting_machine.rb')

unless ENV['RACK_ENV'] == 'production'
  require 'rspec/core/rake_task'
  require 'coveralls/rake/task'
  RSpec::Core::RakeTask.new
  Coveralls::RakeTask.new

  task :default => [:spec, 'coveralls:push']
end

namespace :run do
  desc 'start app'
  task :app do
    sh 'rackup -o 0.0.0.0'
  end

  desc 'start redis and run sidekiq'
  task :queue do
    sh 'redis-server &'
    sh 'sidekiq -r ./lib/voting_machine.rb'
  end
end
