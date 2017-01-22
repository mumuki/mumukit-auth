module Mumukit::Auth
  class Client
    attr_reader :id, :secret

    def initialize(options={})
      config = Mumukit::Auth.config.clients[options[:client] || :default]
      @id = config[:id]
      @secret = config[:secret]
    end

    def decoded_secret
      JWT.base64url_decode(secret)
    end
  end
end