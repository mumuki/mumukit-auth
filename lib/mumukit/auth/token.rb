module Mumukit::Auth
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

    def verify_client!
      raise Mumukit::Auth::InvalidTokenError.new('aud mismatch') if client.id != jwt['aud']
    end

    def encode
      client.encode jwt
    end

    def self.from_rack_env(env)
      new(env.dig('omniauth.auth', 'extra', 'raw_info') || {})
    end

    def self.encode(uid, metadata, client = Mumukit::Auth::Client.new)
      new({aud: client.id, metadata: metadata, uid: uid}, client).encode
    end

    def self.decode(encoded, client = Mumukit::Auth::Client.new)
      new client.decode(encoded), client
    rescue JWT::DecodeError => e
      raise Mumukit::Auth::InvalidTokenError.new(e)
    end

    def self.encode_header(uid, metadata)
      'Bearer ' + encode(uid, metadata)
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

