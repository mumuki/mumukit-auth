class Mumukit::Auth::Permissions
  include Mumukit::Auth::Roles
  include Mumukit::Auth::Protection

  delegate :empty?, to: :scopes

  attr_accessor :scopes

  def initialize(scopes={})
    raise 'invalid scopes' if scopes.any? { |key, value| value.class != Mumukit::Auth::Scope }

    @scopes = scopes.with_indifferent_access
  end

  # Deprecated: use `allows` or `authorizes?` instead
  def has_permission?(role, thing)
    warn "Don't use has_permission?\n" +
         "Use allows? if want to validate a slug-like object\n" +
         "Use authorizes? if you want to validate an authorizable - grant-like or slug-like - object"
    if thing.is_a?(Mumukit::Auth::Grant::Base)
      warn "Using authorizes?"
      authorizes?(role, thing)
    else
      warn "Using allows?"
      allows?(role, thing)
    end
  end

  # tells wether this permissions
  # authorize the given authorizable object for the given role,
  # or any of its parent roles.
  def authorizes?(role, authorizable)
    Mumukit::Auth::Role.parse(role).authorizes?(authorizable, self)
  end

  # Similar to `authorizes?`, but specialized for slug-like objects
  def allows?(role, slug_like)
    authorizes? role, slug_like.to_mumukit_slug
  end

  # tells wether this permissions
  # authorize the given authorizable object for the specific given role
  def role_authorizes?(role, authorizable)
    scope_for(role).authorizes?(authorizable)
  end

  def has_role?(role)
    scopes[role].present?
  end

  def scope_for(role)
    self.scopes[role] ||= Mumukit::Auth::Scope.new
  end

  # Deprecated: use `student_granted_organizations` organizations instead
  def accessible_organizations
    warn "Don't use accessible_organizations, since this method is probably not doing what you would expect.\n" +
         "Use student_granted_organizations if you still need its behaviour"
    student_granted_organizations
  end

  # Answers the organizations for which the user has been explicitly granted acceses as student.
  # This method does not include the organizations the user has access because of the roles hierarchy
  def student_granted_organizations
    granted_organizations_for :student
  end

  def granted_organizations_for(role)
    scope_for(role)&.grants&.flat_map { |grant| grant.granted_organizations }.to_set
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
    other.scopes.all? { |role, scope| authorizes_all?(role, scope) }
  end

  def grant_strings_for(role)
    scope_for(role).grants.map(&:to_s)
  end

  def as_json(options={})
    scopes.as_json(options)
  end

  def self.parse(hash)
    return new if hash.blank?

    new(hash.map { |role, grants| [role, Mumukit::Auth::Scope.parse(grants)] }.to_h)
  end

  def self.reparse(something)
    something ||= {}
    parse(something.to_h)
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

  def assign_to?(other, previous)
    diff = previous.as_set ^ other.as_set
    diff.all? { |role, grant| authorizes?(role, grant) }
  end

  def protect_permissions_assignment!(other, previous)
    raise Mumukit::Auth::UnauthorizedAccessError unless assign_to?(self.class.reparse(other), previous)
  end

  def as_set
    Set.new scopes.flat_map { |role, scope| scope.grants.map {|grant| [role, grant]} }
  end

  def ==(other)
    self.class == other.class && self.scopes == other.scopes
  end

  alias_method :eql?, :==

  def hash
    scopes.hash
  end

  def to_s
    '!' + scopes.map { |role, scope| "#{role}:#{scope}" }.join(';')
  end

  def inspect
    "<Mumukit::Auth::Permissions #{to_s}>"
  end

  def to_h
    as_json
  end

  private

  def authorizes_all?(role, scope)
    scope.grants.all? { |grant| authorizes? role, grant }
  end

end
