module Mumukit::Auth
  class Permissions

    def initialize(grants)
      @grants = grants
    end

    def as_json
      to_s
    end

    def to_s
      @grants.map(&:to_s).join(':')
    end

    def allows?(slug)
      @grants.any? do |grant|
        grant.allows? slug
      end
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

  end
end
