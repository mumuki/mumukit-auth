class String
  def to_mumukit_slug
    Mumukit::Auth::Slug.parse self
  end
end

module Mumukit::Auth
  class Slug
    attr_accessor :first, :second

    alias_method :organization, :first

    alias_method :repository, :second
    alias_method :course, :second
    alias_method :content, :second

    def initialize(first, second)
      raise 'slug first part must be non-nil' unless first
      raise 'slug second part must be non-nil' unless second

      @first = first
      @second = second
    end

    def match_first(first)
      match self.first, first
    end

    def match_second(second)
      match self.second, second
    end

    def rebase(new_organizaton)
      self.class.new new_organizaton, repository
    end

    def ==(o)
      self.class == o.class && self.normalize.eql?(o.normalize)
    end

    def eql?(o)
      self.class == o.class && to_s == o.to_s
    end

    def hash
      to_s.hash
    end

    def to_s
      "#{first}/#{second}"
    end

    def normalize!
      @first = normalize_part @first
      @second = normalize_part @second
      self
    end

    def normalize
      dup.normalize!
    end

    def inspect
      "<Mumukit::Auth::Slug #{to_s}>"
    end

    def to_mumukit_slug
      self
    end

    # Tells wether the given grant
    # is authorized by this slug
    #
    # This method exist in order to implement double dispatching
    # for both grant and slugs authorization
    #
    # See:
    #  * `Mumukit::Auth::Grant::Base#authorized_by?`
    #  * `Mumukit::Auth::Grant::Base#allows?
    #  * `Mumukit::Auth::Grant::Base#includes?`
    def authorized_by?(grant)
      grant.allows? self
    end

    def self.from_options(hash)
      first = hash[:first] || hash[:organization]
      second = hash[:second] || hash[:repository] || hash[:course] || hash[:content]
      new(first, second)
    end

    def self.join(*parts)
      raise Mumukit::Auth::InvalidSlugFormatError, 'Slugs must have up to two parts' if parts.length > 2

      if parts.first.is_a? Hash
        from_options parts.first
      else
        new(*parts.pad_with('_', 2))
      end
    end

    def self.join_s(*args)
      join(*args).to_s
    end

    def self.parse(slug)
      validate_slug! slug

      self.new *slug.split('/')
    end

    def self.any
      parse '_/_'
    end

    def self.normalize(first, second)
      new(first, second).normalize!
    end

    private

    def normalize_part(slug_part)
      slug_part.split('.').map(&:parameterize).join('.')
    end

    def match(pattern, part)
      pattern == '_' || pattern == part
    end

    def self.validate_slug!(slug)
      unless slug =~ /\A[^\/\n]+\/[^\/\n]+\z/
        raise Mumukit::Auth::InvalidSlugFormatError, "Invalid slug: #{slug}. It must be in first/second format"
      end
    end
  end

  class InvalidSlugFormatError < StandardError
  end
end



