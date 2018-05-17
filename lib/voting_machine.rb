require 'sinatra/base'
require 'singleton'
require 'json'
require 'yaml'
require 'sidekiq'
require 'socket'

require_relative 'voting_machine/vote_worker'

module VotingMachine
  class App < Sinatra::Base
    QUESTION = YAML.load(
      File.open(
        File.join(
          File.dirname(__FILE__), '..', 'config/question.yml'
        )
      )
    )

    before do
      headers 'Access-Control-Allow-Origin' => '*',
              'Access-Control-Allow-Methods' => ['OPTIONS', 'GET', 'POST']
    end

    get '/' do
      redirect '/question', 302
    end

    get '/question' do
      QUESTION.to_json
    end

    get '/addresses' do
      {
        addresses: Socket.
                   ip_address_list.
                   select { |a| a.ipv4? }.
                   map { |a| a.ip_address }.
                   delete_if { |a| a[0..2] == '127' }.
                   sort
      }.to_json
    end

    post '/vote' do
      choice = JSON.parse(request.body.read)['choice'].to_i
      VoteWorker.perform_async({
        choice: QUESTION['options'][choice]
      })
    end

    options '*' do
      response.headers['Allow'] = [
        'HEAD',
        'GET',
        'PUT',
        'POST',
        'DELETE',
        'OPTIONS'
      ]
      response.headers['Access-Control-Allow-Headers'] = [
        'X-Requested-With',
        'X-HTTP-Method-Override',
        'Content-Type',
        'Cache-Control',
        'Accept'
      ]
      200
    end

    not_found do
      content_type :json
      status 404
      {found: 'nope'}.to_json
    end

    run! if app_file == $0
  end
end
