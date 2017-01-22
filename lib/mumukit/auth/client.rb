module Mumukit::Auth
  class Client
    attr_reader :id, :secret

    def initialize(options={})
      with_config options do |config|
        @id = config[:id]
        @secret = config[:secret]
      end
    end

    def decoded_secret
      JWT.base64url_decode(secret)
    end

    private

    def with_config(options)
      client = options[:client] || :default
      config = Mumukit::Auth.config.clients[client]

      raise "client config for #{client} is missing" if config.blank?
      raise "client id for #{client} is missing" if config[:id].blank?
      raise "client secret for #{client} is missing" if config[:secret].blank?

      yield config
    end
  end
end