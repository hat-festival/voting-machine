module VotingMachine
  class MastodonWorker
    include Sidekiq::Worker

    def perform choice
      VotingMachine::Helpers.mastodon_client.create_status VotingMachine::Helpers.social_status choice
    end
  end
end
