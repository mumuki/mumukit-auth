require_relative '../spec_helper'

describe Mumukit::Auth::Token do
  let(:client) { Mumukit::Auth::Client.new }

  describe '#verify!' do
    let(:ok) { Mumukit::Auth::Token.new({'aud' => 'foo'}, client) }
    let(:nok) { Mumukit::Auth::Token.new({'aud' => 'bar'}, client) }

    it { expect { nok.verify_client! }.to raise_error(Mumukit::Auth::InvalidTokenError) }
    it { expect { ok.verify_client! }.to_not raise_error }
  end

  describe 'decode_header' do
    let(:header) { Mumukit::Auth::Token.encode_header('foo@bar.com', foo: 'bar') }

    it { expect(Mumukit::Auth::Token.decode_header(header).metadata).to json_like foo: 'bar' }
  end

  describe 'extract_from_header' do
    let(:token) { Mumukit::Auth::Token.extract_from_header('Bearer foo') }

    it { expect(token).to eq 'foo' }
  end

  describe 'permissions' do
    let(:token) { Mumukit::Auth::Token.new(jwt, client) }

    context 'when empty metadata' do
      let(:jwt) { {'metadata' => {}} }
      it { expect(token.metadata).to eq({}) }
    end

    context 'when no metadata' do
      let(:jwt) { {} }
      it { expect(token.metadata).to eq({}) }
    end
  end
end
