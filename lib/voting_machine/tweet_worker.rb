module VotingMachine
  class TweetWorker
    include Sidekiq::Worker

    def perform choice

      client = Twitter::REST::Client.new do |config|
        config.consumer_key        = ENV["CONSUMER_KEY"]
        config.consumer_secret     = ENV["CONSUMER_SECRET"]
        config.access_token        = ENV["TOKEN"]
        config.access_token_secret = ENV["SECRET"]
      end
      # require "pry" ; binding.pry
      # client.user_timeline.map { |t| client.destroy_status t.id }

      client.update """A vote for %s

Current scores:

%s

bit.ly/hat-village
      """ % [
        VotingMachine::Helpers::QUESTION['options'][choice],
        Equestreum::Chain.aggregate.map do |k, v|
          "%s: %d votes" % [VotingMachine::Helpers::QUESTION['options'][k.to_s], v]
        end.join("\n")
      ]
    end
  end
end
