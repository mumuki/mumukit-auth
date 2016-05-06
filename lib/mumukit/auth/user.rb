require 'auth0'

module Mumukit::Auth::User

  def self.update_metadata(social_id, data)
    client.update_user_metadata social_id, metadata_for(social_id).merge(data)
  end

  def self.metadata_for(social_id)
    user = get_user social_id
    metadata = {}
    apps.each do |app|
      metadata[app] = user[app] if user[app].present?
    end
    metadata
  end

  def self.apps
    ['bibliotheca', 'classroom', 'admin']
  end

  def self.get_user(social_id)
    client.user social_id
  end

  def self.client
    Auth0Client.new(
        :client_id => ENV['MUMUKI_AUTH0_CLIENT_ID'],
        :client_secret => ENV['MUMUKI_AUTH0_CLIENT_SECRET'],
        :domain => "mumuki.auth0.com"
    )
  end

end