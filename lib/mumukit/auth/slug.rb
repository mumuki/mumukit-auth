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

    alias_method :eql?, :==

    def hash
      to_s.hash
    end

    def to_s
      "#{first}/#{second}"
    end

    def inspect
      "<Mumukit::Auth::Slug #{to_s}>"
    end

    def to_mumukit_slug
      self
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



