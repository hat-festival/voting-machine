require 'sinatra/base'
require 'tilt/erubis'
require 'json'
require 'yaml'

require_relative 'voting_machine/helpers'
require_relative 'voting_machine/racks'

module VotingMachine
  class App < Sinatra::Base
    helpers do
      include VotingMachine::Helpers
    end

    get '/' do
      headers 'Vary' => 'Accept'

      respond_to do |wants|
        wants.html do
          @content = '<h1>Hello from VotingMachine</h1>'
          @title = 'VotingMachine'
          @github_url = CONFIG['github_url']
          erb :index
        end

        wants.json do
          {
            app: 'VotingMachine'
          }.to_json
        end
      end
    end

    # start the server if ruby file executed directly
    run! if app_file == $0

    not_found do
      status 404
      @title = '404'
      erb :oops
    end
  end
end
