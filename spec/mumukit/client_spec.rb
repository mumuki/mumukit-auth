require_relative '../spec_helper'

describe Mumukit::Auth::Client do

  it { expect(Mumukit::Auth::Client.new.id).to eq default_test_client_id }
  it { expect(Mumukit::Auth::Client.new(client: 'default').id).to eq default_test_client_id }
  it { expect(Mumukit::Auth::Client.new(client: :default).id).to eq default_test_client_id }

  it { expect { Mumukit::Auth::Client.new(client: :nonexistent) }.to raise_error 'client config for nonexistent is missing' }
end