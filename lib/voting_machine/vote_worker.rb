module VotingMachine
  class VoteWorker
    include Sidekiq::Worker

    def perform params
      choice = params['choice']
      Equestreum::Chain.grow choice.to_sym
      fork { exec 'mpg123','-q', "public/media/sounds/#{choice}.mp3" }
      wait
    end
  end
end
