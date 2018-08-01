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
            'options' => {
              'horses' => 'One hundred duck-sized horses?',
              'duck' => 'One horse-sized duck?'
            }
          }
        )
      end
    end

    context 'POST' do
      it 'receives a vote' do
        post '/vote', { choice: :horses }.to_json
        expect(last_response).to be_ok
        expect(VoteWorker).to have_enqueued_sidekiq_job(
          {'choice' => 'horses'}
        )
      end
    end

    context 'CORS headers' do
      it 'sets the correct headers' do
        options '/vote'
        expect(last_response).to be_ok
        expect(last_response.original_headers['Access-Control-Allow-Origin']).to eq '*'
        expect(last_response.original_headers['Access-Control-Allow-Methods']).to eq (
          ['OPTIONS', 'GET', 'POST']
        )
        expect(last_response.original_headers['Access-Control-Allow-Headers']).to eq (
          ['X-Requested-With', 'X-HTTP-Method-Override', 'Content-Type',
           'Cache-Control', 'Accept']
        )
        expect(last_response.original_headers['Allow']).to eq (
          ['HEAD', 'GET', 'PUT', 'POST', 'DELETE', 'OPTIONS']
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

    # it 'sets the difficulty' do
    #   expect(Equestreum::Chain).to receive(:difficulty=).with 4
    #   expect(YAML).to receive(:load_file).and_return({})
    #   file = double('file')
    #   expect(File).to receive(:open).and_yield(file)
    #   # expect(file).to receive(:write).with("---\ndifficulty: 4\n")
    #
    #   patch '/difficulty', { difficulty: 4 }.to_json
    # end
  end
end
