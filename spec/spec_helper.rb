$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'mumukit/auth'

require 'base64'

Mumukit::Auth.configure do |c|
  c.client_id = 'foo'
  c.client_secret = Base64.encode64 'bar'
  c.daybreak_name = ENV['MUMUKI_DAYBREAK_NAME'] || 'test.db'
end

RSpec::Matchers.define :json_like do |expected, options={}|
  except = options[:except] || []
  match do |actual|
    actual.as_json.with_indifferent_access.except(except) == expected.as_json.with_indifferent_access
  end

  failure_message_for_should do |actual|
    <<-EOS
    expected: #{expected.as_json} (#{expected.class})
         got: #{actual.as_json} (#{actual.class})
    EOS
  end

  failure_message_for_should_not do |actual|
    <<-EOS
    expected: value != #{expected.as_json} (#{expected.class})
         got:          #{actual.as_json} (#{actual.class})
    EOS
  end
end

RSpec.configure do |config|
  config.after(:each) do
    Mumukit::Auth::Store.clean_env!
  end
end
