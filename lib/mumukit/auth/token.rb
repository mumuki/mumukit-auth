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
    rescue JWT::DecodeError => e
      raise Mumukit::Auth::InvalidTokenError.new(e)
    end

    def self.build(grantish, uuid = SecureRandom.hex(4), iat = DateTime.current.utc.to_i)
      new grantish.to_mumukit_auth_grant, uuid, iat
    end
  end


  class Grant
    def to_mumukit_auth_grant
      self
    end

    def new_token
      Token.build(self)
    end
  end
end

class String
  def to_mumukit_auth_grant
    Mumukit::Auth::Grant.new(self)
  end
end
