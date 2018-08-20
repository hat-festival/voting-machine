module VotingMachine
  class VoteWorker
    include Sidekiq::Worker

    def perform params
      choice = params['choice']
      Equestreum::Chain.grow choice.to_sym
      if RUBY_PLATFORM =~ /arm.*-linux/
        Process.fork { exec 'mpg123','-q', "public/media/sounds/#{choice}.mp3" }
        Process.wait2
      end

      SocialWorkers::TweetWorker.perform_async choice
      SocialWorkers::MastodonWorker.perform_async choice
    end
  end
end
