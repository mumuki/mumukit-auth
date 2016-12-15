module Mumukit::Auth
  class Scope
    attr_accessor :grants

    def initialize(grants=[])
      @grants = grants
    end

    def protect!(resource_slug)
      raise Mumukit::Auth::UnauthorizedAccessError.new(unauthorized_message(resource_slug)) unless allows?(resource_slug)
    end

    def allows?(resource_slug)
      any_grant? { |grant| grant.allows? resource_slug }
    end

    def add_grant!(*grants)
      self.grants.push *grants.map(&:to_mumukit_grant)
    end

    def remove_grant!(grant)
      grant = grant.to_mumukit_grant
      self.grants.delete(grant)
    end

    def to_s
      grants.map(&:to_s).join(':')
    end

    def present?
      to_s.present?
    end

    def self.parse(string)
      new(string.split(':').map(&:to_mumukit_grant))
    end

    def as_json(_options={})
      to_s
    end

    private

    def any_grant?(&block)
      @grants.any?(&block)
    end

    def unauthorized_message(slug)
      "Unauthorized access to #{slug}. Permissions are #{to_s}"
    end
  end
end
