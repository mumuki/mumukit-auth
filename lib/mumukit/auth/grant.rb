module Mumukit::Auth
  class Grant
    def as_json(options={})
      to_s
    end

    def [](resource)
      (self.class.slug? resource) ? allows?(resource) : access?(resource)
    end

    def self.slug?(resource_identifier)
      /.*\/.*/.matches? resource_identifier
    end

    def self.parse(pattern)
      case pattern
        when '*' then
          AllGrant.new
        when /(.*)\/\*/
          OrgGrant.new($1)
        else
          SingleGrant.new(pattern)
      end
    end
  end

  class AllGrant < Grant
    def allows?(slug)
      true
    end

    def access?(organization)
      true
    end

    def to_s
      '*'
    end
  end

  class SingleGrant < Grant
    def initialize(slug)
      @slug = slug
    end

    def allows?(slug)
      @slug == slug
    end

    def access?(organization)
      @slug.split('/')[0] == organization
    end

    def to_s
      @slug
    end
  end

  class OrgGrant < Grant
    def initialize(org)
      @org = org
    end

    def allows?(slug)
      /^#{@org}\/.*/.matches? slug
    end

    def access?(organization)
      @org == organization
    end

    def to_s
      "#{@org}/*"
    end
  end
end
