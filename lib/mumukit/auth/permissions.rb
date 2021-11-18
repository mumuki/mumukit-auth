class Mumukit::Auth::Permissions
  include Mumukit::Auth::Roles
  include Mumukit::Auth::Protection

  attr_accessor :scopes

  def initialize(scopes={})
    @scopes = {}.with_indifferent_access
    add_scopes! scopes
  end

  def has_permission?(role, resource_slug)
    role.to_mumukit_role.allows?(resource_slug, self)
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

  def empty?
    scopes.all? { |_, it| it.empty? }
  end

  def compact!
    old_scopes = @scopes.dup
    @scopes = {}.with_indifferent_access

    old_scopes.each do |role, scope|
      scope.grants.each do |grant|
        push_and_compact! role, grant
      end
    end
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

  def any_granted_organizations
    scopes.values.flat_map(&:grants).map(&:organization).to_set
  end

  def any_granted_roles
    scopes.select { |_, scope| scope.present? }.keys.to_set
  end

  def granted_organizations_for(role)
    scope_for(role)&.grants&.map(&:organization).to_set
  end

  def add_permission!(role, *grants)
    role = role.to_mumukit_role
    grants.each { |grant| push_and_compact! role, grant }
  end

  def add_scopes!(scopes)
    raise 'invalid scopes' if scopes.any? { |key, value| value.class != Mumukit::Auth::Scope }
    scopes.each { |role, scope| add_permission! role, *scope.grants }
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
    diff.all? { |role, grant| has_permission?(role, grant) }
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

  def has_all_permissions?(role, scope)
    scope.grants.all? { |grant| has_permission? role, grant }
  end

  def push_and_compact!(role, grant)
    role = role.to_mumukit_role
    grant = grant.to_mumukit_grant

    scopes.each do |other_role, other_scope|
      other_role = other_role.to_mumukit_role

      if other_role.narrower_than?(role)
        other_scope.remove_narrower_grants!(grant)
      elsif other_role.broader_than?(role) && other_scope.has_broader_grant?(grant)
        return
      end
    end
    scope_for(role.to_sym).add_grant! grant
  end
end
