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
      JWT::Decode.base64url_decode(secret)
    end

    def encode(jwt_hash)
      JWT.encode(jwt_hash, decoded_secret, algorithm)
    end

    def decode(encoded_jwt)
      JWT.decode(encoded_jwt, decoded_secret, true, { algorithm: algorithm })[0]
    end

    def algorithm
      'HS256'
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