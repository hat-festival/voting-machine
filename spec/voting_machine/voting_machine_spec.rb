module VotingMachine
  describe App do
    context 'GET' do
      it 'serves the question' do
        get '/question'
        expect(last_response).to be_ok
        expect(JSON.parse last_response.body).to eq (
          {
            'description' => 'Ducks or Horses?',
            'premise' => 'Would you rather fight',
            'options' => [
              'One hundred duck-sized horses?',
              'One horse-sized duck?'
            ]
          }
        )
      end
    end

    context 'POST' do
      it 'receives a vote' do
        post '/vote', { choice: 0 }.to_json
        expect(last_response).to be_ok
        expect(VoteWorker).to have_enqueued_sidekiq_job(
          {'choice' => 'One hundred duck-sized horses?'}
        )
      end
    end

    context 'redirect' do
      it 'redirects to the question' do
        get '/'
        expect(last_response.status).to eq 302
        expect(URI.parse(last_response.header['Location']).path).to eq '/question'
      end
    end

    context 'addresses' do
      it 'exposes a list of ip addresses' do
        get '/addresses'
        expect(last_response).to be_ok
        expect(JSON.parse(last_response.body)['addresses']).to be_an Array
      end
    end
  end
end
