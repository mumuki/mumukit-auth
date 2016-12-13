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

    def to_s
      @grants.map(&:to_s).uniq.join(':')
    end

    def present?
      to_s.present?
    end

    def self.parse(string)
      new(string.split(':').map { |grant_pattern| Grant.parse(grant_pattern) })
    end

    def as_json(_options={})
      grants.join(':')
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
