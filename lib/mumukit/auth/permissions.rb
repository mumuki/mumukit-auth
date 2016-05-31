module Mumukit::Auth
  class Permissions

    def initialize(grants)
      @grants = grants
    end

    def protect!(slug)
      raise Mumukit::Auth::UnauthorizedAccessError.new(unauthorized_message(slug)) unless allows?(slug)
    end

    def allows?(slug)
      @grants.any? do |grant|
        grant.allows? slug
      end
    end

    def as_json
      to_s
    end

    def to_s
      @grants.map(&:to_s).uniq.join(':')
    end

    def present?
      to_s.present?
    end

    def self.dump(permission)
      permission.to_s
    end

    def self.load(pattern)
      parse(pattern)
    end

    def self.parse(pattern)
      new(pattern.split(':').map { |grant_pattern| Grant.parse(grant_pattern) })
    end

    private

    def unauthorized_message(slug)
      "Unauthorized access to #{slug}. Permissions are #{to_s}"
    end
  end
end
