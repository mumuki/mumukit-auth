class Mumukit::Auth::Permissions
  include Mumukit::Auth::Roles

  attr_accessor :scopes

  def initialize(scopes={})
    raise 'invalid scopes' if scopes.any? { |key, value| value.class.is_a? Mumukit::Auth::Scope  }

    @scopes = scopes.with_indifferent_access
  end

  def has_permission?(role, resource_slug)
    !!scope_for(role)&.allows?(resource_slug) || parent_scope_for(role).present? && has_permission?(parent_scope_for(role), resource_slug)
  end

  def protect!(scope, slug)
    scope_for(scope).protect!(slug)
  end

  def has_role?(role)
    scopes[role].present?
  end

  def scope_for(role)
    self.scopes[role] || Mumukit::Auth::Scope.parse(role)
  end

  def parent_scope_for(role)
    Mumukit::Auth::Scope.parse(role).parent
  end

  def add_permission!(role, *grants)
    self.scopes[role] ||= Mumukit::Auth::Scope.parse(role)
    scope_for(role)&.add_grant! *grants
  end

  def remove_permission!(role, grant)
    scope_for(role)&.remove_grant!(grant)
  end

  def update_permission!(role, old_grant, new_grant)
    remove_permission! role, old_grant
    add_permission! role, new_grant
  end

  def as_json(options={})
    scopes.as_json(options)
  end

  def self.parse(hash)
    new(Hash[hash.map { |role, grants| [role, Mumukit::Auth::Scope.parse(role, grants)] }])
  end

  def self.load(json)
    if json.nil?
      parse({})
    else
      parse(JSON.parse(json))
    end
  end

  def self.dump(user)
    user.to_json
  end

end
