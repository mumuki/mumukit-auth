require 'jwt'

module Mumukit::Auth
  class Token
    SECRET = 'MY-SECRET'
    ALGORITHM = 'HS512'

    attr_reader :grant, :iat, :uuid

    def initialize(grant, uuid, iat)
      @grant = grant
      @uuid = uuid
      @iat = iat
    end

    def as_jwt
      as_json
    end

    def encode
      JWT.encode as_jwt, SECRET, ALGORITHM
    end

    def self.decode(encoded)
      jwt = JWT.decode(encoded, SECRET, true, {:algorithm => ALGORITHM})[0]
      Token.build jwt['grant'], jwt['uuid'], jwt['iat']
    end

    def self.build(slug, uuid = SecureRandom.hex(4), iat = DateTime.current.utc.to_i)
      new Grant.new(slug), uuid, iat
    end
  end
end