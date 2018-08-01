module VotingMachine
  module Helpers
    QUESTION = YAML.load_file File.join File.dirname(__FILE__), '..', '..', '..', 'config/question.yml'

    def set_difficulty diff
      Equestreum::Chain.difficulty = diff
      path = File.join File.dirname(__FILE__), '..', '..', '..', 'config/equestreum.yml'
      y = YAML.load_file path
      y['difficulty'] = diff
      File.open path, 'w' do |f|
        f.write y.to_yaml
      end
    end

    def this_host
      port = request.port == 80 ? '' : ":#{request.port}"
      "#{request.scheme}://#{request.host}#{port}"
    end
  end
end
