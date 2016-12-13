class Mumukit::Auth::Permissions
  include Mumukit::Auth::Roles

  attr_accessor :scopes

  def initialize(scopes={})
    @scopes = scopes
  end

  def has_role?(role, resource_slug)
    !!scopes[role]&.allows?(resource_slug)
  end

  def scope_for(role)
    self.scopes[role] ||= Mumukit::Auth::Scope.new
  end

  def add_scope!(role, *grants)
    scope_for(role).grants << grants
  end

  def remove_scope!(role, grant)
    scope_for(role).grants.delete(grant)
  end

  def update_scope!(role, old_grant, new_grant)
    remove_scope! role, old_grant
    add_scope! role, new_grant
  end

  def as_json(options={})
    scopes.as_json(options)
  end

  def self.parse(hash)
    new(Hash[hash.map { |role, grants| [role, Mumukit::Auth::Scope.parse(grants)] }])
  end

  def self.load(json)
    parse(JSON.parse(json))
  end

  def self.dump(user)
    user.to_json
  end

end
