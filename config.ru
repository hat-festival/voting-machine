require 'sidekiq/web'
require File.join(File.dirname(__FILE__), 'lib/voting_machine.rb')

run Rack::URLMap.new '/' => VotingMachine::App,
                     '/sidekiq' => Sidekiq::Web
