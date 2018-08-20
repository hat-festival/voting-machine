module VotingMachine
  module SocialUtils
    def social_status choice
      status = """A vote for %s

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

    def twitter_client
      Twitter::REST::Client.new do |config|
        config.consumer_key        = ENV["TWITTER_CONSUMER_KEY"]
        config.consumer_secret     = ENV["TWITTER_CONSUMER_SECRET"]
        config.access_token        = ENV["TWITTER_TOKEN"]
        config.access_token_secret = ENV["TWITTER_SECRET"]
      end
    end

    def mastodon_client
      Mastodon::REST::Client.new base_url: ENV["MASTODON_BASE_URL"], bearer_token: ENV["MASTODON_BEARER_TOKEN"]
    end
  end
end
