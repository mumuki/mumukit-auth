class Mumukit::Auth::User

  attr_accessor :uid, :user

  def initialize(uid, user=nil)
    @uid = uid
    @user = user
  end

  def add_permission!(key, permission)
    metadata.add_permission!(key, permission)
  end

  def remove_permission!(key, permission)
    metadata.remove_permission!(key, permission)
  end

  def permissions_string
    apps.select { |app| @user[app].present? }.map { |app| {app.to_s => @user[app]} }.reduce({}, :merge).to_json
  end

  def metadata
    @metadata ||= Mumukit::Auth::Metadata.load(permissions_string)
  end

  def permissions_for(app)
    metadata[app]['permissions']
  end

  def apps
    ['bibliotheca', 'classroom', 'admin', 'atheneum']
  end

  def librarian?(slug)
    metadata.librarian? slug
  end

  def admin?(slug)
    metadata.admin? slug
  end

  def teacher?(slug)
    metadata.teacher? slug
  end

  def student?(slug)
    metadata.student? slug
  end

end
