require 'jwt'

module Mumukit::Auth
  class Client
    attr_reader :id, :secret

    def initialize(options={})
      @id = Mumukit::Auth.config.client_ids[options[:client] || :default]
      @secret = Mumukit::Auth.config.client_secrets[options[:client] || :default]
    end

    def decoded_secret
      JWT.base64url_decode(secret)
    end
  end

  class Token
    attr_reader :jwt, :client

    def initialize(jwt, client)
      @jwt = jwt
      @client = client
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

    def verify_client!
      raise Mumukit::Auth::InvalidTokenError.new('aud mismatch') if client.id != jwt['aud']
    end

    def encode
      JWT.encode(jwt, client.decoded_secret)
    end

    def self.from_rack_env(env)
      new(env.dig('omniauth.auth', 'extra', 'raw_info') || {})
    end

    def self.encode_dummy_auth_header(uid, metadata)
      'dummy token ' + encode(uid, metadata)
    end

    def self.encode(uid, metadata, client = Mumukit::Auth::Client.new)
      new({aud: client.id, metadata: metadata, uid: uid}, client).encode
    end

    def self.decode(encoded, client = Mumukit::Auth::Client.new)
      new JWT.decode(encoded, client.decoded_secret)[0], client
    rescue JWT::DecodeError => e
      raise Mumukit::Auth::InvalidTokenError.new(e)
    end

    def self.decode_header(header, client = Mumukit::Auth::Client.new)
      decode extract_from_header(header), client
    end

    def self.extract_from_header(header)
      raise Mumukit::Auth::InvalidTokenError.new('missing authorization header') if header.nil?
      header.split(' ').last
    end

  end
end

