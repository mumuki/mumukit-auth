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

    def ==(o)
      self.class == o.class && to_s == o.to_s
    end

    alias_method :eql?, :==

    def hash
      to_s.hash
    end

    protected

    def to_s
      "#{first}/#{second}"
    end

    def self.join(*parts)
      raise 'Slugs must have up to two parts' if parts.length > 2
      new (parts + ['_'] * 2).take(2)
    end

    def self.from(slug)
      validate_slug! slug

      self.new *slug.split('/')
    end

    private

    def self.validate_slug!(slug)
      unless slug =~ /.*\/.*/
        raise Mumukit::Auth::InvalidSlugFormatError, 'Slug must be in first/second format'
      end
    end
  end

  class InvalidSlugFormatError < StandardError
  end
end



