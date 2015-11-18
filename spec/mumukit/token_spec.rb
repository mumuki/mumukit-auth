require 'spec_helper'

describe Mumukit::Auth::Token do
  let(:slug) { 'Mumukit/Mumukit-pdep-fundamentos-ruby-guia-34-el-method-missing' }
  let(:token) { Mumukit::Auth::Token.build(slug) }


  describe '#encode' do
    it { expect(token.as_jwt['grant']).to eq slug }
    it { expect(token.encode).to_not eq Mumukit::Auth::Token.build(slug).encode }
    it { expect(token.encode).to eq token.encode }
    it { expect(token.encode.size).to be < 384 }

  end

  describe '#decode' do
    let(:decoded) { Mumukit::Auth::Token.decode(token.encode) }
    it { expect(decoded.grant.to_s).to eq slug }
    it { expect(decoded.uuid).to eq token.uuid }
    it { expect(decoded.iat).to eq token.iat }

    it { expect { Mumukit::Auth::Token.decode('123445') }.to raise_error(Mumukit::Auth::InvalidTokenError) }
    it { expect { Mumukit::Auth::Token.decode(nil) }.to raise_error(Mumukit::Auth::InvalidTokenError) }
  end

end