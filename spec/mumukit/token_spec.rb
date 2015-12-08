require 'spec_helper'

describe Mumukit::Auth::Token do
  let(:slug) { 'Mumukit/Mumukit-pdep-fundamentos-ruby-guia-34-el-method-missing' }
  let(:token) { Mumukit::Auth::Token.build(slug) }

  describe '#encode' do
    it { expect(token.as_jwt['permissions']).to eq slug }
    it { expect(token.encode).to_not eq Mumukit::Auth::Token.build(slug).encode }
    it { expect(token.encode).to eq token.encode }
    it { expect(token.encode.size).to be < 384 }

  end

  describe '#decode' do
    let(:decoded) { Mumukit::Auth::Token.decode(token.encode) }
    it { expect(decoded.permissions.to_s).to eq slug }
    it { expect(decoded.uuid).to eq token.uuid }
    it { expect(decoded.iat).to eq token.iat }

    it { expect { Mumukit::Auth::Token.decode('123445') }.to raise_error(Mumukit::Auth::InvalidTokenError) }
    it { expect { Mumukit::Auth::Token.decode(nil) }.to raise_error(Mumukit::Auth::InvalidTokenError) }
  end

  describe '#new_token' do
    it { expect(Mumukit::Auth::Permissions.parse('*').new_token).to be_a(Mumukit::Auth::Token) }
  end

  describe '#to_mumukit_auth_permissions' do
    it { expect('*'.to_mumukit_auth_permissions).to be_a(Mumukit::Auth::Permissions) }
    it { expect('!'.to_mumukit_auth_permissions).to be_a(Mumukit::Auth::Permissions) }
    it { expect(nil.to_mumukit_auth_permissions).to be_a(Mumukit::Auth::Permissions) }
    it { expect('mumuki/*:pdep-utn/*'.to_mumukit_auth_permissions).to be_a(Mumukit::Auth::Permissions) }

  end

end
