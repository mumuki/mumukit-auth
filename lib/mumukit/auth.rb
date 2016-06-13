require 'active_support/all'

require 'mumukit/auth/hash'
require 'mumukit/auth/version'
require 'mumukit/auth/exceptions'
require 'mumukit/auth/grant'
require 'mumukit/auth/metadata'
require 'mumukit/auth/token'
require 'mumukit/auth/permissions'
require 'mumukit/auth/user'

require 'ostruct'

class Regexp
  def matches?(string)
    !!(self =~ string)
  end
end

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
