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
      @first = first
      @second = second
    end

    def match_first(first)
      match self.first, first
    end

    def match_second(second)
      match self.second, second
    end

    def ==(o)
      self.class == o.class && to_s == o.to_s
    end

    def to_s
      "#{first}/#{second}"
    end

    def to_mumukit_slug
      self
    end

    def self.join(*parts)
      raise 'Slugs must have up to two parts' if parts.length > 2
      new(*(parts + ['_'] * 2).take(2))
    end

    def self.parse(slug)
      validate_slug! slug

      self.new *slug.split('/')
    end

    private

    def match(pattern, part)
      pattern == '_' || pattern == part
    end

    def self.validate_slug!(slug)
      unless slug =~ /.*\/.*/
        raise Mumukit::Auth::InvalidSlugFormatError, "Invalid slug: #{slug}. It must be in first/second format"
      end
    end
  end

  class InvalidSlugFormatError < StandardError
  end
end



