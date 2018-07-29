module VotingMachine
  class VoteWorker
    include Sidekiq::Worker

    def perform params
      Equestreum::Chain.grow params['choice'].to_sym
    end
  end
end
