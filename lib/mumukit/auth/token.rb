require 'jwt'

module Mumukit::Auth
  class Token
    attr_reader :jwt

    def initialize(jwt)
      @jwt = jwt
    end

    def verify_client!
      raise Mumukit::Auth::InvalidTokenError.new('aud mismatch') if Mumukit::Auth.config.client_id != jwt['aud']
    end

    def permissions(app)
      jwt.dig('app_metadata', app, 'permissions').to_mumukit_auth_permissions
    end

    def self.decode_header(header)
      raise Mumukit::Auth::InvalidTokenError.new('missing authorization header') if header.nil?
      decode header.split(' ').last
    end

    def self.decode(encoded)
      Token.new JWT.decode(encoded, decoded_secret)[0]
    rescue JWT::DecodeError => e
      raise Mumukit::Auth::InvalidTokenError.new(e)
    end

    def self.encode_dummy_auth_header(metadata)
      encoded_token = JWT.encode(
          {aud: Mumukit::Auth.config.client_id,
           app_metadata: metadata},
          decoded_secret)
      'dummy token ' + encoded_token
    end

    def self.decoded_secret
      JWT.base64url_decode(Mumukit::Auth.config.client_secret)
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
