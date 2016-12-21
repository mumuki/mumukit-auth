require 'jwt'

module Mumukit::Auth
  class Token
    attr_reader :jwt

    def initialize(jwt)
      @jwt = jwt
    end

    def metadata
      @metadata ||= jwt['metadata'] || {}
    end

    def uid
      @uid ||= jwt['email'] || jwt['sub']
    end

    def permissions
      @permissions ||= Mumukit::Auth::Store.get uid
    end

    def protect!(scope, resource_slug)
      permissions.protect! scope, resource_slug
    end

    def verify_client!
      raise Mumukit::Auth::InvalidTokenError.new('aud mismatch') if Mumukit::Auth.config.client_id != jwt['aud']
    end

    def encode
      JWT.encode(jwt, self.class.decoded_secret)
    end

    def self.from_rack_env(env)
      new(env.dig('omniauth.auth', 'extra', 'raw_info') || {})
    end

    def self.encode_dummy_auth_header(metadata)
      'dummy token ' + encode(metadata)
    end

    def self.encode(metadata)
      new(aud: Mumukit::Auth.config.client_id, metadata: metadata).encode
    end

    def self.decode(encoded)
      Token.new JWT.decode(encoded, decoded_secret)[0]
    rescue JWT::DecodeError => e
      raise Mumukit::Auth::InvalidTokenError.new(e)
    end

    def self.decode_header(header)
      raise Mumukit::Auth::InvalidTokenError.new('missing authorization header') if header.nil?
      decode header.split(' ').last
    end

    def self.decoded_secret
      JWT.base64url_decode(Mumukit::Auth.config.client_secret)
    end
  end
end

