require 'active_support/all'
require 'mumukit/core'
require 'daybreak'

require_relative './auth/array'
require_relative './auth/roles'
require_relative './auth/slug'
require_relative './auth/version'
require_relative './auth/exceptions'
require_relative './auth/grant'
require_relative './auth/token'
require_relative './auth/scope'
require_relative './auth/permissions'
require_relative './auth/store'

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
