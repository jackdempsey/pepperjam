module Pepperjam
  class Base
    include HTTParty
    format :json

    @@credentials = {}
    @@default_params = {}

    def initialize(params)
      raise ArgumentError, "Init with a Hash; got #{params.class} instead" unless params.is_a?(Hash)

      params.each do |key, val|
        instance_variable_set("@#{key}".intern, val)
        instance_eval " class << self ; attr_reader #{key.intern.inspect} ; end "
      end
    end

    def user_id=(id)
      @@credentials['user_id'] = id.to_s
    end

    def pass=(pass)
      @@credentials['pass'] = pass.to_s
    end

    def self.base_url
      "http://api.pepperjamnetwork.com/"
    end

    def self.validate_params!(provided_params, available_params, default_params = {})
      params = default_params.merge(provided_params)
      invalid_params = params.select{|k,v| !available_params.include?(k.to_s)}.map{|k,v| k}
      raise ArgumentError.new("Invalid parameters: #{invalid_params.join(', ')}") if invalid_params.length > 0
    end

    def self.get_service(path, query)
      query.keys.each{|k| query[k.to_s] = query.delete(k)}

      results = []
      begin
        # pairs = [] ; query.each_pair{|k,v| pairs << "#{k}=#{v}" } ; p "#{path}&#{pairs.join('&')}"
        response = get(path, :query => query, :timeout => 30)
      rescue Timeout::Error
        nil
      end

      validate_response(response)

      JSON.parse(response.body)
    end

    def self.credentials
      unless @@credentials && @@credentials.length > 0
        # there is no offline or test mode for Pepperjam - so I won't include any credentials in this gem
        config_file = ["config/pepperjam.yml", File.join(ENV['HOME'], '.pepperjam.yaml')].select{|f| File.exist?(f)}.first

        unless File.exist?(config_file)
          warn "Warning: config/pepperjam.yml does not exist. Put your PepperJam username and password in ~/.pepperjam.yml to enable live testing."
        else
          @@credentials = YAML.load(File.read(config_file))
        end
      end
      @@credentials
    end # credentails

    def self.validate_response(response)
      raise ArgumentError, "There was an error connecting to PepperJam's reporting server: #{response.response.body.inspect}." if response.response.body.include?("error")
    end

    def self.first(params)
      find(params).first
    end
  end # Base
end # Pepperjam
