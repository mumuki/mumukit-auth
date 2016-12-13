class Mumukit::Auth::User
  include Mumukit::Auth::Roles

  attr_accessor :uid, :permissions

  def initialize(uid, permissions=[])
    @uid = uid
    @permissions = permissions
  end

  def has_role?(role, resource_slug)
    !!permission_as(role)&.allows?(resource_slug)
  end

  def permission_as(role)
    permissions.find { |it| it.role == role }
  end

  def add_scope!(role, *scopes)
    permission = permission_as(role)
    if permission.present?
      permission.scopes += scopes
    else
      permissions << Mumukit::Auth::Permission.new(role, scopes)
    end
  end

  def remove_scope!(role, scope)
    permission_as(role).& scopes.& delete(scope)
  end

  def replace_scope!(role, old, new)
    remove_scope! role, old
    add_scope! role, new
  end

  def as_json(_options={})
    {uid: uid, permissions: permissions.map { |it| it.as_json(_options) }.inject(&:merge)}
  end

  def self.parse(hash)
    new uid: hash[:uid], permissions: hash[:permissions].map { |k, v| Permission.parse k => v }
  end

  def self.load(json)
    parse(JSON.parse(json))
  end

  def self.dump(user)
    user.to_json
  end

end
