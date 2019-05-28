module Mumukit::Auth::Protection
  def protect!(role, slug_like)
    raise Mumukit::Auth::UnauthorizedAccessError,
          "Unauthorized access to #{slug_like} as #{role}. Scope is `#{scope_for role}`" unless allows?(role, slug_like)
  end

  def protect_delegation!(other)
    other ||= {}
    raise Mumukit::Auth::UnauthorizedAccessError,
          "Unauthorized delegation to #{other.to_h}" unless delegate_to?(Mumukit::Auth::Permissions.parse(other.to_h))
  end
end
