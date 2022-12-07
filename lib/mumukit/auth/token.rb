module Mumukit::Auth
  class Token
    attr_reader :jwt, :client

    def initialize(jwt = {}, client = Mumukit::Auth::Client.new)
      @jwt = jwt
      @client = client
    end

    def metadata
      @metadata ||= jwt['metadata'] || {}
    end

    def uid
      @uid ||= jwt['uid'] || jwt['email'] || jwt['sub']
    end

    def organization
      @organization ||= jwt['org']
    end

    def expiration
      @expiration ||= Time.at jwt['exp']
    end

    def subject_id
      @subject_id ||= jwt['sbid']
    end

    def subject_type
      @subject_type ||= jwt['sbt']
    end

    def verify_client!
      raise Mumukit::Auth::InvalidTokenError.new('aud mismatch') if client.id != jwt['aud']
    end

    def encode
      client.encode jwt
    end

    def encode_header
      'Bearer ' + encode
    end

    def self.decode(encoded, client = Mumukit::Auth::Client.new)
      new client.decode(encoded), client
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

    def self.build(uid, client = Mumukit::Auth::Client.new,
                   expiration: nil, organization: nil,
                   subject_id: nil, subject_type: nil,
                   metadata: {})
      new({
          'uid' => uid,
          'aud' => client.id,
          'exp' => expiration&.to_i,
          'org' => organization,
          'metadata' => metadata,
          'sbid' => subject_id,
          'sbt' => subject_type
        }.compact,
        client)
    end

    def self.load(encoded)
      if encoded.present?
        decode encoded rescue nil
      end
    end

    def self.dump(decoded)
      decoded.encode
    end
  end
end
