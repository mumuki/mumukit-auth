module Mumukit::Auth::Protection
  def protect!(role, slug)
    raise Mumukit::Auth::UnauthorizedAccessError,
          "Unauthorized access to #{slug} as #{role}. Scope is `#{scope_for role}`" unless has_permission?(role, slug)
  end

  def protect_delegation!(other)
    other ||= {}
    raise Mumukit::Auth::UnauthorizedAccessError,
          "Unauthorized delegation to #{other.to_h}" unless delegate_to?(Mumukit::Auth::Permissions.parse(other.to_h))
  end
end