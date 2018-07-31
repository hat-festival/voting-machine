module VotingMachine
  class VoteWorker
    include Sidekiq::Worker

    def perform params
      choice = params['choice']
      Equestreum::Chain.grow choice.to_sym
      Process.fork { exec 'mpg123','-q', "public/media/sounds/#{choice}.mp3" }
      Process.wait2
    end
  end
end
