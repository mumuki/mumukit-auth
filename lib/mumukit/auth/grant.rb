class String
  def to_mumukit_grant
    Mumukit::Auth::Grant.parse self
  end
end

module Mumukit::Auth::Grant
  def self.parse(pattern)
    grant_types.each do |type|
      type.try_parse(pattern).try { |it| return it }
    end
  end

  def self.grant_types
    custom_grant_types + [AllGrant, FirstPartGrant, SingleGrant]
  end

  def self.add_custom_grant_type!(grant_type)
    custom_grant_types << grant_type
  end

  def self.remove_custom_grant_type!(grant_type)
    custom_grant_types.delete(grant_type)
  end

  def self.custom_grant_types
    @custom_grant_types ||= []
  end

  class Base
    def as_json(options={})
      to_s
    end

    def to_mumukit_grant
      self
    end

    def ==(other)
      other.class == self.class && to_s == other.to_s
    end

    alias_method :eql?, :==

    def hash
      to_s.hash
    end

    def inspect
      "<Mumukit::Auth::Grant #{to_s}>"
    end
  end

  class AllGrant < Base
    def allows?(_resource_slug)
      true
    end

    def includes?(_)
      true
    end

    def to_s
      '*'
    end

    def to_mumukit_slug
      Mumukit::Auth::Slug.new '*', '*'
    end

    def self.try_parse(pattern)
      new if ['*', '*/*'].include? pattern
    end
  end

  class FirstPartGrant < Base
    attr_accessor :first

    def initialize(first)
      @first = first.downcase
    end

    def allows?(resource_slug)
      resource_slug.to_mumukit_slug.normalize!.match_first @first
    end

    def to_s
      "#{@first}/*"
    end

    def to_mumukit_slug
      Mumukit::Auth::Slug.new @first, '*'
    end

    def includes?(other)
      case other
      when FirstPartGrant then other.first == first
      when SingleGrant then other.slug.first == first
      else false
      end
    end

    def self.try_parse(pattern)
      new($1) if pattern =~ /(.*)\/\*/
    end
  end

  class SingleGrant < Base
    attr_accessor :slug

    def initialize(slug)
      @slug = slug.normalize
    end

    def allows?(resource_slug)
      resource_slug = resource_slug.to_mumukit_slug.normalize!
      resource_slug.match_first(@slug.first) && resource_slug.match_second(@slug.second)
    end

    def includes?(other)
      other.is_a?(SingleGrant) && other.slug == slug
    end

    def to_s
      @slug.to_s
    end

    def to_mumukit_slug
      @slug
    end

    def self.try_parse(pattern)
      new(Mumukit::Auth::Slug.parse pattern)
    end
  end
end
