require_relative '../spec_helper'

describe Mumukit::Auth::Token do

  describe '#verify!' do
    let(:ok) { Mumukit::Auth::Token.new('aud' => 'foo') }
    let(:nok) { Mumukit::Auth::Token.new('aud' => 'bar') }

    it { expect { nok.verify_client! }.to raise_error(Mumukit::Auth::InvalidTokenError) }
    it { expect { ok.verify_client! }.to_not raise_error }
  end

  describe 'decode_header' do
    let(:header) { Mumukit::Auth::Token.encode_dummy_auth_header(myapp: {permissions: '*'}) }

    it { expect(Mumukit::Auth::Token.decode_header(header).permissions('myapp')).to_not be nil }

  end

  describe 'permissions' do
    let(:token) { Mumukit::Auth::Token.new(metadata) }
    context 'when metadata' do
      let(:metadata) { {'user_metadata' => {'myapp' => {'permissions' => '*'}}} }

      it { expect(token.permissions 'myapp').to be_instance_of(Mumukit::Auth::Permissions) }
    end

    context 'when no metadata' do
      let(:metadata) { {'user_metadata' => {}} }

      it { expect(token.permissions 'myapp').to be_instance_of(Mumukit::Auth::Permissions) }
    end

  end

  describe '#to_mumukit_auth_permissions' do
    it { expect('*'.to_mumukit_auth_permissions).to be_a(Mumukit::Auth::Permissions) }
    it { expect('!'.to_mumukit_auth_permissions).to be_a(Mumukit::Auth::Permissions) }
    it { expect(nil.to_mumukit_auth_permissions).to be_a(Mumukit::Auth::Permissions) }
    it { expect('mumuki/*:pdep-utn/*'.to_mumukit_auth_permissions).to be_a(Mumukit::Auth::Permissions) }

  end

end
