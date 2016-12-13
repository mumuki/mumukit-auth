module Mumukit::Auth
  class Grant
    def as_json(options={})
      to_s
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
      resource_slug.first == @first
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
      @slug == resource_slug
    end

    def to_s
      @slug
    end
  end
end
