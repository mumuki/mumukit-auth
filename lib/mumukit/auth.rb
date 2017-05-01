require 'active_support/all'
require 'mumukit/core'
require 'jwt'

require_relative './auth/array'
require_relative './auth/role'
require_relative './auth/roles'
require_relative './auth/slug'
require_relative './auth/version'
require_relative './auth/exceptions'
require_relative './auth/grant'
require_relative './auth/client'
require_relative './auth/token'
require_relative './auth/scope'
require_relative './auth/protection'
require_relative './auth/permissions'

require 'ostruct'

module Mumukit
  module Auth
    def self.configure
      @config ||= defaults
      yield @config
    end

    def self.defaults
      struct.tap do |config|
        config.clients = struct default: {
            id: ENV['MUMUKI_AUTH_CLIENT_ID'],
            secret: ENV['MUMUKI_AUTH_CLIENT_SECRET']
        }
      end
    end

    def self.config
      @config
    end
  end
end
