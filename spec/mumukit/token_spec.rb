require_relative '../spec_helper'

describe Mumukit::Auth::Token do

  describe '#verify!' do
    let(:ok) { Mumukit::Auth::Token.new('aud' => 'foo') }
    let(:nok) { Mumukit::Auth::Token.new('aud' => 'bar') }

    it { expect { nok.verify_client! }.to raise_error(Mumukit::Auth::InvalidTokenError) }
    it { expect { ok.verify_client! }.to_not raise_error }
  end

  describe 'decode_header' do
    let(:header) { Mumukit::Auth::Token.encode_dummy_auth_header(foo: 'bar') }

    it { expect(Mumukit::Auth::Token.decode_header(header).metadata).to json_like foo: 'bar' }
  end

  describe 'extract_from_header' do
    let(:token) { Mumukit::Auth::Token.extract_from_header('Bearer foo') }

    it { expect(token).to eq 'foo'}
  end

  describe 'permissions' do
    let(:token) { Mumukit::Auth::Token.new(jwt) }

    context 'when empty metadata' do
      let(:jwt) { {'metadata' => {}} }
      it { expect(token.metadata).to eq({}) }
    end

    context 'when no metadata' do
      let(:jwt) { {} }
      it { expect(token.metadata).to eq({}) }
    end

    context 'protect' do
      let(:jwt) { {'sub' => uid} }
      context 'when social_id' do
        let(:uid) { 'facebook|1' }
        before { Mumukit::Auth::Store.set! uid, {student: 'test/_'} }
        it { expect { token.protect! :student, 'test/_' }.not_to raise_error }
        it { expect { token.protect! :teacher, 'example/test' }.to raise_error(Mumukit::Auth::UnauthorizedAccessError) }
      end
    end
  end
end
