module VotingMachine
  class TweetWorker
    include Sidekiq::Worker

    def perform choice
      vote = VotingMachine::Helpers::QUESTION['options'][choice]
      s = """A vote for %s

Current scores:

""" % VotingMachine::Helpers::QUESTION['options'][choice]

      Equestreum::Chain.aggregate.map do |k, v|
        s += "%s: %d votes\n" % [VotingMachine::Helpers::QUESTION['options'][k.to_s], v]
      end

      s += """
bit.ly/hat-village
"""

      client = Twitter::REST::Client.new do |config|
        config.consumer_key        = ENV["CONSUMER_KEY"]
        config.consumer_secret     = ENV["CONSUMER_SECRET"]
        config.access_token        = ENV["TOKEN"]
        config.access_token_secret = ENV["SECRET"]
      end

      client.update s
    end
  end
end
