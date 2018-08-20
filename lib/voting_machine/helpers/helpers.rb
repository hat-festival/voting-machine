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


    def excluded_ip? ip_address
      excludeds = [
        IPAddr.new('169.254.0.0/16'),
        IPAddr.new('172.17.0.0/16'),
        IPAddr.new('172.18.0.0/16'),
        IPAddr.new('127.0.0.0/8')
      ].freeze


      if ip_address.is_a? String
        ip_address = IPAddr.new ip_address
      end

      excludeds.any? { |ip| ip.include? ip_address }
    end
  end
end
