require 'spec_helper'

describe Mumukit::Auth::User do
  describe 'build_metadata' do
    let!(:auth0_stub) { double('auth0') }
    let(:auth0) { Mumukit::Auth::User.new('auth0|1') }
    before { expect(Auth0Client).to receive(:new).and_return(auth0_stub) }
    before { expect(auth0_stub).to receive(:user).with('auth0|1').and_return(user_data) }

    context 'when no atheneum permissions' do
      let(:user_data) { { id: 1, bibliotheca: { permissions: 'foo/bar' }, classroom: { permissions: 'foo/baz' } }.deep_stringify_keys }

      it { expect(auth0.metadata.as_json).to eq('bibliotheca' => { 'permissions' => 'foo/bar' }, 'classroom' => { 'permissions' => 'foo/baz' }) }
      it { expect(auth0.social_id).to eq('auth0|1') }
      it { expect(auth0.user).to eq(user_data) }
    end

    context 'when init from email' do
      let(:user_data) { { id: 2, atheneum: { permissions: 'foo/bar' } }.deep_stringify_keys }
      let(:user) { Mumukit::Auth::User.from_email 'aguspina87@gmail.com' }
      before { expect(Auth0Client).to receive(:new).and_return(auth0_stub) }
      before { expect(auth0_stub).to receive(:users).with('email:aguspina87@gmail.com').and_return([{ 'user_id' => 'auth0|1' }]) }

      it { expect(user.metadata.as_json).to eq({'atheneum' => {'permissions' => 'foo/bar' } })}
    end

  end
end
