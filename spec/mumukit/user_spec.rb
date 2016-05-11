require 'spec_helper'

describe Mumukit::Auth::User do
  describe 'build_metadata' do
    let!(:auth0_stub) { double('auth0') }
    let(:user_data) { { id: 1, bibliotheca: 'foo/bar', classroom: 'foo/baz' }.stringify_keys }
    let(:auth0) { Mumukit::Auth::User.new('auth0|1') }

    before { expect(Auth0Client).to receive(:new).and_return(auth0_stub) }
    before { expect(auth0_stub).to receive(:user).with('auth0|1').and_return(user_data) }

    it { expect(auth0.metadata).to eq('bibliotheca' => 'foo/bar', 'classroom' => 'foo/baz') }
    it { expect(auth0.social_id).to eq('auth0|1') }
    it { expect(auth0.user).to eq(user_data) }
  end

end
