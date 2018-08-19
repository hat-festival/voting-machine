module VotingMachine
  module Helpers
    QUESTION = YAML.load_file File.join File.dirname(__FILE__), '..', '..', '..', 'config/question.yml'

    def set_difficulty diff
      Equestreum::Chain.difficulty = diff
      path = File.join File.dirname(__FILE__), '..', '..', '..', 'config/equestreum.yml'
      y = YAML.load_file path
      y['difficulty'] = diff
      File.open path, 'w' do |f|
        f.write y.to_yaml
      end
    end

    def this_host
      port = request.port == 80 ? '' : ":#{request.port}"
      "#{request.scheme}://#{request.host}#{port}"
    end


    def excluded_ip? ip_address
      excludeds = [
        IPAddr.new('169.254.0.0/16'),
        IPAddr.new('172.17.0.0/16'),
        IPAddr.new('172.18.0.0/16'),
        IPAddr.new('127.0.0.0/8')
      ].freeze


      if ip_address.is_a? String
        ip_address = IPAddr.new ip_address
      end

      excludeds.any? { |ip| ip.include? ip_address }
    end

    def self.social_status choice
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

    def self.twitter_client
      Twitter::REST::Client.new do |config|
        config.consumer_key        = ENV["TWITTER_CONSUMER_KEY"]
        config.consumer_secret     = ENV["TWITTER_CONSUMER_SECRET"]
        config.access_token        = ENV["TWITTER_TOKEN"]
        config.access_token_secret = ENV["TWITTER_SECRET"]
      end
    end

    def self.mastodon_client
      Mastodon::REST::Client.new base_url: ENV["MASTODON_BASE_URL"], bearer_token: ENV["MASTODON_BEARER_TOKEN"] 
    end
  end
end
