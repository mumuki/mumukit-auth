class Mumukit::Auth::Permissions
  include Mumukit::Auth::Roles
  include Mumukit::Auth::Protection

  delegate :empty?, to: :scopes

  attr_accessor :scopes

  def initialize(scopes={})
    raise 'invalid scopes' if scopes.any? { |key, value| value.class != Mumukit::Auth::Scope }

    @scopes = scopes.with_indifferent_access
  end

  def has_permission?(role, resource_slug)
    Mumukit::Auth::Role.parse(role).allows?(resource_slug, self)
  end

  def role_allows?(role, resource_slug)
    scope_for(role).allows?(resource_slug)
  end

  def has_role?(role)
    scopes[role].present?
  end

  def scope_for(role)
    self.scopes[role] ||= Mumukit::Auth::Scope.new
  end

  def accessible_organizations
    scope_for(:student)&.grants&.map { |grant| grant.to_mumukit_slug.organization }.to_set
  end

  def add_permission!(role, *grants)
    scope_for(role).add_grant! *grants
  end

  def merge(other)
    self.class.new(scopes.merge(other.scopes) { |_key, left, right| left.merge right })
  end

  def remove_permission!(role, grant)
    scope_for(role).remove_grant!(grant)
  end

  def update_permission!(role, old_grant, new_grant)
    remove_permission! role, old_grant
    add_permission! role, new_grant
  end

  def delegate_to?(other)
    other.scopes.all? { |role, scope| has_all_permissions?(role, scope) }
  end

  def grant_strings_for(role)
    scope_for(role).grants.map(&:to_s)
  end

  def as_json(options={})
    scopes.as_json(options)
  end

  def self.parse(hash)
    return new if hash.blank?

    new(Hash[hash.map { |role, grants| [role, Mumukit::Auth::Scope.parse(grants)] }])
  end

  def self.load(json)
    if json.nil?
      parse({})
    else
      parse(JSON.parse(json))
    end
  end

  def self.dump(permission)
    permission.to_json
  end

  private

  def has_all_permissions?(role, scope)
    scope.grants.all? { |grant| has_permission? role, grant }
  end

end
