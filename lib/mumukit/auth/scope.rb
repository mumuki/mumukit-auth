module Mumukit::Auth
  class Scope
    attr_accessor :grants

    def initialize(grants=[])
      @grants = []
      add_grant! *grants
    end

    def allows?(authorizable)
      any_grant? { |grant| authorizable.authorized_by? grant  }
    end

    def add_grant!(*grants)
      grants.each { |grant| push_and_compact! grant }
    end

    def remove_grant!(grant)
      grant = grant.to_mumukit_grant
      self.grants.delete(grant)
    end

    def merge(other)
      self.class.new grants + other.grants
    end

    def ==(other)
      self.class == other.class && self.grants == other.grants
    end

    alias_method :eql?, :==

    def hash
      grants.hash
    end

    def to_s
      grants.map(&:to_s).join(':')
    end

    def inspect
      "<Mumukit::Auth::Scope #{to_s}>"
    end

    def present?
      to_s.present?
    end

    def self.parse(string='')
      new(string.split(':').map(&:to_mumukit_grant))
    end

    def as_json(_options={})
      to_s
    end

    private

    def any_grant?(&block)
      @grants.any?(&block)
    end

    def push_and_compact!(grant)
      grant = grant.to_mumukit_grant
      return if has_broader_grant? grant
      remove_narrower_grants! grant
      grants << grant
    end

    def remove_narrower_grants!(grant)
      grants.reject! { |it| grant.includes? it }
    end

    def has_broader_grant?(grant)
      grants.any? { |it| it.includes? grant }
    end
  end
end
