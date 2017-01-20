$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'mumukit/auth'
require 'mumukit/core/rspec'

require 'base64'

Mumukit::Auth.configure do |c|
  c.client_ids = {default: 'foo'}
  c.client_secrets = {default: Base64.encode64('bar')}
  c.persistence_strategy = Mumukit::Auth::PermissionsPersistence::Daybreak.new 'test'
end

RSpec.configure do |config|
  config.after(:each) do
    Mumukit::Auth::Store.clean!
  end
end
