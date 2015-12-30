require 'jwt'

module Mumukit::Auth
  class Token
    attr_reader :jwt

    def initialize(jwt)
      @jwt = jwt
    end

    def self.decode_header(header)
      raise Mumukit::Auth::InvalidTokenError.new('missing authorization header') if header.nil?
      decode header.split(' ').last
    end

    def self.decode(encoded)
      Token.new JWT.decode(encoded, JWT.base64url_decode(client_secret))[0]
    rescue JWT::DecodeError => e
      raise Mumukit::Auth::InvalidTokenError.new(e)
    end

    def verify_client!
      raise Mumukit::Auth::InvalidTokenError.new('aud mismatch') if client_id != jwt['aud']
    end

    def permissions(app)
      jwt['user_metadata'][app].try { |it| it['permissions'] }.to_mumukit_auth_permissions
    end

    private

    def client_secret
      Mumukit::Auth.config.client_secret
    end

    def client_id
      Mumukit::Auth.config.client_id
    end
  end


  class Permissions
    def to_mumukit_auth_permissions
      self
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
