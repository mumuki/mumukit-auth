require 'spec_helper'

describe Mumukit::Auth::User do
  describe 'build_metadata' do
    let(:user) { { bibliotheca: 'foo/bar', classroom: 'foo/baz' }.stringify_keys }
    let(:auth0) { double('auth0') }

    before { expect(Auth0Client).to receive(:new) { auth0 }}
    before { expect(auth0).to receive(:update_user_metadata).with('auth0|1', user.merge(atheneum: 'test/*')) }
    before { expect(Mumukit::Auth::User).to receive(:get_user).with('auth0|1').and_return(user) }

    it { expect { Mumukit::Auth::User.update_metadata('auth0|1', atheneum: 'test/*') }.not_to raise_error }
  end

end
