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

namespace :social do
  namespace :twitter do
    desc 'delete all tweets'
    task :purge do
      client = VotingMachine::Helpers.twitter_client
      client.user_timeline.each do |t|
        id = t.id
        puts "Deleting Tweet #{id}"
        client.destroy_status id
      end
    end
  end

  namespace :mastodon do
    desc 'delete all toots'
    task :purge do
      client = VotingMachine::Helpers.mastodon_client
      client.statuses(ENV['MASTODON_ACCOUNT_ID']).map do |s|
        id = s.id
        puts "Deleting Toot #{id}"
        client.destroy_status id
      end
    end
  end

  desc 'destroy all statuses'
  task :purge do
    Rake::Task['social:twitter:purge'].invoke
    Rake::Task['social:mastodon:purge'].invoke
  end
end
