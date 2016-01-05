require 'active_support/all'

require 'mumukit/auth/hash'
require 'mumukit/auth/version'
require 'mumukit/auth/exceptions'
require 'mumukit/auth/grant'
require 'mumukit/auth/token'
require 'mumukit/auth/permissions'

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
