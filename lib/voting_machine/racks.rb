module VotingMachine
  class App < Sinatra::Base
    before do
      headers 'Access-Control-Allow-Origin' => '*',
              'Access-Control-Allow-Methods' => ['OPTIONS', 'GET', 'POST']
    end
  end
end
