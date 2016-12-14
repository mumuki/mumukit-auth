class String
  def to_mumukit_grant
    Mumukit::Auth::Grant.parse self
  end
end


module Mumukit::Auth
  class Grant
    def as_json(options={})
      to_s
    end

    def to_mumukit_grant
      self
    end

    def ==(other)
      other.class == self.class && to_s == other.to_s
    end

    def self.parse(pattern)
      case pattern
        when '*' then
          AllGrant.new
        when /(.*)\/\*/
          FirstPartGrant.new($1)
        else
          SingleGrant.new(Slug.parse pattern)
      end
    end
  end

  class AllGrant < Grant
    def allows?(_resource_slug)
      true
    end

    def to_s
      '*'
    end
  end

  class FirstPartGrant < Grant
    def initialize(first)
      @first = first
    end

    def allows?(resource_slug)
      resource_slug.to_mumukit_slug.match_first @first
    end

    def to_s
      "#{@first}/*"
    end
  end

  class SingleGrant < Grant
    def initialize(slug)
      @slug = slug
    end

    def allows?(resource_slug)
      resource_slug = resource_slug.to_mumukit_slug
      resource_slug.match_first(@slug.first) && resource_slug.match_second(@slug.second)
    end

    def to_s
      @slug.to_s
    end
  end
end
