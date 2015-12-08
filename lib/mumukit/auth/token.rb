require 'jwt'

module Mumukit::Auth
  class Token
    SECRET = 'MY-SECRET'
    ALGORITHM = 'HS512'

    attr_reader :permissions, :iat, :uuid

    def initialize(permissions, uuid, iat)
      @permissions = permissions
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
      Token.build jwt['permissions'], jwt['uuid'], jwt['iat']
    rescue JWT::DecodeError => e
      raise Mumukit::Auth::InvalidTokenError.new(e)
    end

    def self.build(permissionish, uuid = SecureRandom.hex(4), iat = DateTime.current.utc.to_i)
      new permissionish.to_mumukit_auth_permissions, uuid, iat
    end
  end


  class Permissions
    def to_mumukit_auth_permissions
      self
    end

    def new_token
      Token.build(self)
    end
  end
end

class String
  def to_mumukit_auth_permissions
    Mumukit::Auth::Permissions.parse(self)
  end
end

class NilClass
  def to_mumukit_auth_permissions
    Mumukit::Auth::Permissions.new([])
  end
end
