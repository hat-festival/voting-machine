module VotingMachine
  class TweetWorker
    include Sidekiq::Worker

    def perform choice
      VotingMachine::Helpers.twitter_client.update VotingMachine::Helpers.social_status choice
    end
  end
end

# require "pry" ; binding.pry
# client.user_timeline.map { |t| client.destroy_status t.id }
