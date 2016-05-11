require 'auth0'

class Mumukit::Auth::User

  attr_accessor :social_id, :user

  def initialize(social_id)
    @social_id = social_id
    @user = client.user @social_id
  end

  def update_metadata(data)
    client.update_user_metadata social_id, metadata.merge(data)
  end

  def metadata
    metadata = {}
    apps.each do |app|
      metadata[app] = @user[app] if @user[app].present?
    end
    metadata
  end

  def apps
    ['bibliotheca', 'classroom', 'admin']
  end

  def client
    Auth0Client.new(
        :client_id => ENV['MUMUKI_AUTH0_CLIENT_ID'],
        :client_secret => ENV['MUMUKI_AUTH0_CLIENT_SECRET'],
        :domain => "mumuki.auth0.com"
    )
  end

end