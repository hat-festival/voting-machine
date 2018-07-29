module VotingMachine
  describe App do
    it 'queues a vote' do
      post '/vote', {choice: :horses}.to_json
      expect(VoteWorker).to have_enqueued_sidekiq_job(
        {'choice' => 'horses'}
      )
      expect(Equestreum::Chain).to receive(:grow).with :horses
      VoteWorker.drain
    end
  end
end
