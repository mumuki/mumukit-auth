$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'mumukit/auth'

require 'base64'

Mumukit::Auth.configure do |c|
  c.client_id = 'foo'
  c.client_secret = Base64.encode64 'bar'
end