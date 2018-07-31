module VotingMachine
  class VoteWorker
    include Sidekiq::Worker

    def perform params
      Equestreum::Chain.grow params['choice'].to_sym
      fork { exec 'mpg123','-q', 'public/media/sounds/coin.mp3' }
    end
  end
end
