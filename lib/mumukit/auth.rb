require 'active_support/all'
require 'mumukit/core'

require_relative './auth/version'
require_relative './auth/exceptions'
require_relative './auth/grant'
require_relative './auth/metadata'
require_relative './auth/token'
require_relative './auth/permissions'
require_relative './auth/user'

require 'ostruct'

module Mumukit
  module Auth
    def self.configure
      @config ||= OpenStruct.new
      yield @config
    end

    def self.config
      @config
    end
  end
end
