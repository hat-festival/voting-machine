module VotingMachine
  class VoteWorker
    include Sidekiq::Worker

    def perform params
      puts "Got a vote: #{params}"
    end
  end
end
