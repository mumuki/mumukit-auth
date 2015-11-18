module Mumukit::Auth
  class Grant
    def initialize(pattern)
      @pattern = pattern
    end

    def allows?(slug)
      case @pattern
        when '*' then
          true
        when /(.*)\/\*/
          !!(Regexp.new("^#{$1}/.*") =~ slug)
        else
          slug == @pattern
      end
    end

    def protect!(slug)
      raise Mumukit::Auth::UnauthorizedAccessError.new(unauthorized_message(slug)) unless allows?(slug)
    end

    def to_s
      @pattern
    end

    def as_json(options={})
      to_s
    end

    private

    def unauthorized_message(slug)
      "Unauthorized access to #{slug}. Permissions are #{@pattern}"
    end
  end
end