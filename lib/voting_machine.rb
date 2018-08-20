require 'sinatra/base'
require 'singleton'
require 'json'
require 'yaml'
require 'sidekiq'
require 'pagy'
require 'pagy/extras/array'
require 'socket'
require 'twitter'
require 'mastodon'
require 'dotenv'
require 'equestreum'

require_relative 'voting_machine/vote_worker'
require_relative 'voting_machine/social_utils'
require_relative 'voting_machine/social_workers/tweet_worker'
require_relative 'voting_machine/social_workers/mastodon_worker'
require_relative 'voting_machine/link_set'
require_relative 'voting_machine/helpers/helpers'

Dotenv.load

module VotingMachine
  class App < Sinatra::Base
    set :public_folder, 'public'
    include Pagy::Backend

    helpers do
      include VotingMachine::Helpers
    end

    before do
      headers 'Access-Control-Allow-Origin' => '*',
              'Access-Control-Allow-Methods' => ['OPTIONS', 'GET', 'POST'],
              'Content-type' => 'application/json'
      Equestreum::Chain.init
    end

    get '/' do
      redirect '/question', 302
    end

    get '/question' do
      halt 200, QUESTION.to_json
    end

    get '/results' do
      data = Equestreum::Chain.aggregate
      results = {}
      data.keys.each do |k|
        results[QUESTION['options'][k.to_s]] = data[k]
      end
      halt 200, results.to_json
    end

    get '/chain' do
      per_page = params[:per_page] ? params[:per_page].to_i : 20
      chain = Equestreum::Chain.revive
      data = {chain_length: chain.count}
      chain.reverse! if params[:reverse]
      begin
        pagy, items = pagy_array chain, items: per_page
        data[:blocks] = items.map { |b| b.to_h }
      rescue Pagy::OutOfRangeError => oore
        data[:blocks] = []
        pagy = oore.pagy
      end

      response.headers['Link'] =
        LinkSet.links "#{this_host}/chain", pagy, query_hash: params

      halt 200, data.to_json
    end

    get '/difficulty' do
      halt 200, { difficulty: Equestreum::Chain.revive.difficulty }.to_json
    end

    patch '/difficulty' do
      diff = JSON.parse(request.body.read)['difficulty']
      set_difficulty diff
      halt 200, {updated: 'OK', difficulty: diff}.to_json
    end

    post '/vote' do
      choice = JSON.parse(request.body.read)['choice']
      VoteWorker.perform_async({
        choice: choice
      })
      halt 200, {vote: 'OK', choice: choice}.to_json
    end

    get '/addresses' do
      halt 200, {
        addresses: Socket.
        ip_address_list.
        select { |a| a.ipv4? }.
        map { |a| a.ip_address }.
        delete_if { |a| excluded_ip? a }.
        sort
      }.to_json
    end

    get '/readme' do
      body = File.read 'README.md'
      if params[:gem]
        body = File.read File.join(Gem.find_latest_files(params[:gem]).last, '..', '..', 'README.md')
      end

      unless params[:entire]
        body = body.split("\n").delete_if { |l| l[0..2] == '[![' }.join("\n").strip
      end

      halt 200, {
        readme: body
      }.to_json
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
      #content_type :json
      halt 404, {found: 'nope'}.to_json
    end

    run! if app_file == $0
  end
end
