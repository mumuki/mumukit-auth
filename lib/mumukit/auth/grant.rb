class String
  def to_mumukit_grant
    Mumukit::Auth::Grant.parse self
  end
end

module Mumukit::Auth::Grant

  # Parses a given string that describes a grant
  # by trying with each grant type, in the following order:
  #
  # 1. All grant
  # 2. Custom grants
  # 3. First Grant
  # 4. Slug grant
  #
  # Raises a `Mumukit::Auth::InvalidGrantFormatError` if the grant is not valid, which happens when
  #
  # * structure is invalid
  # * `something/_`, `_/something`, `_/_` format is used
  def self.parse(pattern)
    grant_types.each do |type|
      type.try_parse(pattern).try { |it| return it }
    end
  end

  def self.grant_types
    [AllGrant] + custom_grant_types + [FirstPartGrant, SingleGrant]
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

    # returns the organizations that are explicitly
    # granted by this grant
    #
    # Custom grants may override this method
    def granted_organizations
      []
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

    # Tells whether the given grant
    # is authorized by this grant
    #
    # This method exist in order to implement double dispatching
    # for both grant and slugs authorization
    #
    # See:
    #  * `Mumukit::Auth::Slug#authorized_by?`
    #  * `Mumukit::Auth::Grant::Base#allows?
    #  * `Mumukit::Auth::Grant::Base#includes?`
    def authorized_by?(grant)
      grant.includes? self
    end

    # tells whether the given slug-like object is allowed by
    # this grant
    required :allows?

    # tells whether the given grant-like object is included
    # in - that is, is not broader than - this grant
    #
    # :warning: Custom grants **should not** override this method
    def includes?(grant_like)
      self == grant_like.to_mumukit_grant
    end

    # Returns a canonical string representation of this grant
    # Equivalent grant **must** have equivalent string representations
    required :to_s
  end

  class AllGrant < Base
    def allows?(_slug_like)
      true
    end

    def includes?(_)
      true
    end

    def to_s
      '*'
    end

    def self.try_parse(pattern)
      new if ['*', '*/*'].include? pattern
    end
  end

  class FirstPartGrant < Base
    attr_accessor :first

    def initialize(first)
      raise Mumukit::Auth::InvalidGrantFormatError, "Invalid first grant. First part must not be _" if  first == '_'
      @first = first.downcase
    end

    def granted_organizations
      [first]
    end

    def allows?(slug_like)
      slug_like.to_mumukit_slug.normalize!.match_first @first
    end

    def to_s
      "#{@first}/*"
    end

    def includes?(grant_like)
      grant = grant_like.to_mumukit_grant
      case grant
      when FirstPartGrant then grant.first == first
      when SingleGrant then grant.slug.first == first
      else false
      end
    end

    def self.try_parse(pattern)
      new($1) if pattern =~ /(.+)\/\*/
    end
  end

  class SingleGrant < Base
    attr_accessor :slug

    def initialize(slug)
      raise Mumukit::Auth::InvalidGrantFormatError, "Invalid slug grant. First part must not be _" if  slug.first == '_'
      raise Mumukit::Auth::InvalidGrantFormatError, "Invalid slug grant. Second part must not be _" if  slug.second == '_'
      @slug = slug.normalize
    end

    def granted_organizations
      [slug.first]
    end

    def allows?(slug_like)
      slug = slug_like.to_mumukit_slug.normalize!
      slug.match_first(@slug.first) && slug.match_second(@slug.second)
    end

    def to_s
      @slug.to_s
    end

    def self.try_parse(pattern)
      new(Mumukit::Auth::Slug.parse pattern)
    rescue Mumukit::Auth::InvalidSlugFormatError => e
        raise Mumukit::Auth::InvalidGrantFormatError, "Invalid slug grant. Cause: #{e}"
    end
  end
end

module Mumukit::Auth
  class InvalidGrantFormatError < StandardError
  end
end
