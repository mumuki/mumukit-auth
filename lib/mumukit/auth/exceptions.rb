module Mumukit::Auth
  class InvalidTokenError < StandardError
  end

  class UnauthorizedAccessError < StandardError
  end

  class EmailNotRegistered < StandardError
  end
end