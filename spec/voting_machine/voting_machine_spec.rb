module VotingMachine
  JSON_HEADERS = { 'HTTP_ACCEPT' => 'application/json' }

  describe App do
    it 'says hello' do
      get '/'
      expect(last_response).to be_ok
      expect(last_response.body).to match /Hello from VotingMachine/
    end

    it 'serves JSON' do
      get '/', nil, JSON_HEADERS
      expect(last_response).to be_ok
      expect(JSON.parse last_response.body).to eq (
        {
          'app' => 'VotingMachine'
        }
      )
    context 'POST' do
      it 'receives a vote' do
        post '/vote', { choice: 0 }.to_json
        expect(last_response).to be_ok
        expect(VoteWorker).to have_enqueued_sidekiq_job(
          {'choice' => 'One hundred duck-sized horses?'}
        )
      end
    end
  end
end
