module Mumukit::Auth
  class InvalidTokenError < StandardError
  end

  class UnauthorizedAccessError < StandardError
    def self.with_message(slug, grants)
      new "Unauthorized access to #{slug}. Permissions are #{grants}"
    end
  end
end