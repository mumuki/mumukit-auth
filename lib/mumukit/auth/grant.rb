module Mumukit::Auth
  class Grant
    def protect!(slug)
      raise Mumukit::Auth::UnauthorizedAccessError.new(unauthorized_message(slug)) unless allows?(slug)
    end

    def as_json(options={})
      to_s
    end

    def self.parse(pattern)
      raise "invalid pattern #{pattern}" unless valid_pattern? pattern
      case pattern
        when '*' then
          AllGrant.new
        when /(.*)\/\*/
          OrgGrant.new($1)
        else
          SingleGrant.new(pattern)
      end
    end

    def self.valid_pattern?(pattern)
      case pattern
        when '*' then
          true
        when '!' then
          true
        when /(.*)\/\*/
          true
        when /(.*)\/(.*)/
          true
        else
          false
      end
    end

    private

    def unauthorized_message(slug)
      "Unauthorized access to #{slug}. Permissions are #{to_s}"
    end
  end

  class AllGrant < Grant
    def allows?(slug)
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

    def to_s
      @slug
    end
  end

  class OrgGrant < Grant
    def initialize(org)
      @org = org
    end

    def allows?(slug)
      !!(Regexp.new("^#{@org}/.*") =~ slug)
    end

    def to_s
      "#{@org}/*"
    end
  end


end
