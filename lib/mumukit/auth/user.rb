require 'auth0'

class Mumukit::Auth::User

  attr_accessor :social_id, :user

  def initialize(social_id, user=nil)
    @social_id = social_id
    @user = user || client.user(@social_id)
  end

  def update_permissions(key, permission)
    metadata.add_permission!(key, permission)
    client.update_user_metadata social_id, metadata.as_json
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

  def client
    self.class.client
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

  def self.from_email(email)
    user = client.users("email:#{email}").first
    raise Mumukit::Auth::EmailNotRegistered.new('There is no user registered with that email.') unless user.present?
    new(user['user_id'])
  end

  def self.client
    Auth0Client.new(
        :client_id => ENV['MUMUKI_AUTH0_CLIENT_ID'],
        :client_secret => ENV['MUMUKI_AUTH0_CLIENT_SECRET'],
        :domain => "mumuki.auth0.com"
    )
  end

end
