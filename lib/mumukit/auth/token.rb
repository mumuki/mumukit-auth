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
      @uid ||= jwt['uid'] || jwt['email'] || jwt['sub']
    end

    def permissions
      @permissions ||= Mumukit::Auth::Store.get uid
    end

    def protect!(scope, resource_slug)
      permissions.protect! scope, resource_slug
    end

    def verify_client!(client = :auth0)
      raise Mumukit::Auth::InvalidTokenError.new('aud mismatch') if Mumukit::Auth.config.client_ids[client] != jwt['aud']
    end

    def encode(client = :auth0)
      JWT.encode(jwt, self.class.decoded_secret(client))
    end

    def self.from_rack_env(env)
      new(env.dig('omniauth.auth', 'extra', 'raw_info') || {})
    end

    def self.encode_dummy_auth_header(uid, metadata, client = :auth0)
      'dummy token ' + encode(uid, metadata, client)
    end

    def self.encode(uid, metadata, client = :auth0)
      new(aud: Mumukit::Auth.config.client_ids[client], metadata: metadata, uid: uid).encode client
    end

    def self.decode(encoded, client = :auth0)
      Token.new JWT.decode(encoded, decoded_secret(client))[0]
    rescue JWT::DecodeError => e
      raise Mumukit::Auth::InvalidTokenError.new(e)
    end

    def self.decode_header(header, client = :auth0)
      decode extract_from_header(header), client
    end

    def self.extract_from_header(header)
      raise Mumukit::Auth::InvalidTokenError.new('missing authorization header') if header.nil?
      header.split(' ').last
    end

    def self.decoded_secret(client = :auth0)
      client_secret = Mumukit::Auth.config.client_secrets[client]
      JWT.base64url_decode(client_secret)
    end
  end
end

