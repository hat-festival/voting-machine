module VotingMachine
  module SocialWorkers
    class MastodonWorker
      include Sidekiq::Worker
      include VotingMachine::SocialUtils

      def perform choice
        mastodon_client.create_status social_status choice
      end
    end
  end
end
