module VotingMachine
  module SocialWorkers
    class TweetWorker
      include Sidekiq::Worker
      include VotingMachine::SocialUtils

      def perform choice
        twitter_client.update social_status choice
      end
    end
  end
end
