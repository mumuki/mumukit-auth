module Mumukit::Auth
  class Permission
    attr_accessor :role, :scopes

    def initialize(role, scopes)
      @role = role
      @scopes = scopes
    end

    def protect!(resource_slug)
      raise Mumukit::Auth::UnauthorizedAccessError.new(unauthorized_message(resource_slug)) unless allows?(resource_slug)
    end

    def allows?(resource_slug)
      any_scope? { |scope| scope.allows? resource_slug }
    end

    def to_s
      @scopes.map(&:to_s).uniq.join(':')
    end

    def present?
      to_s.present?
    end

    def self.parse(hash)
      new(hash.first.first.to_sym, hash.first.second.split(':').map { |grant_pattern| Grant.parse(grant_pattern) })
    end

    def as_json(_options={})
      {role => scopes.join(':')}
    end

    private

    def any_scope?(&block)
      @scopes.any?(&block)
    end

    def unauthorized_message(slug)
      "Unauthorized access to #{slug}. Permissions are #{to_s}"
    end
  end
end
