require_relative '../spec_helper'

describe Mumukit::Auth::Token do
  let(:client) { Mumukit::Auth::Client.new }

  describe '#verify_client!' do
    let(:ok) { Mumukit::Auth::Token.new({'aud' => 'foo'}, client) }
    let(:nok) { Mumukit::Auth::Token.new({'aud' => 'bar'}, client) }

    it { expect { nok.verify_client! }.to raise_error(Mumukit::Auth::InvalidTokenError) }
    it { expect { ok.verify_client! }.to_not raise_error }
  end

  describe 'decode_header' do
    context 'with current encode_header' do
      let(:header) { Mumukit::Auth::Token.build('foo@bar.com', metadata: {foo: 'bar'}).encode_header }

      it { expect(Mumukit::Auth::Token.decode_header(header).metadata).to json_like foo: 'bar' }
    end
  end

  describe 'build' do
    let(:token) do
      Mumukit::Auth::Token.build(
        'foo@bar.com',
        expiration: expiration,
        organization: 'central',
        subject_type: 'exercise',
        subject_id: 485)
    end

    context 'not expired' do
      let(:expiration) { 5.minutes.from_now.round }

      it { expect(token.expiration).to eq expiration }
      it { expect(token.organization).to eq 'central' }
      it { expect(token.subject_type).to eq 'exercise' }
      it { expect(token.subject_id).to eq 485 }

      it do
        expect(token.jwt.except('exp')).to eq "aud"=>"foo",
                                              "metadata"=>{},
                                              "org"=>"central",
                                              "sbid"=>485,
                                              "sbt"=>"exercise",
                                              "uid"=>"foo@bar.com"
      end

      it { expect(Mumukit::Auth::Token.decode(token.encode).expiration).to eq expiration }
      it { expect(token.encode).to start_with 'ey' }

    end

    context 'expired' do
      let(:expiration) { 5.minutes.ago.round }

      it { expect(token.encode).to start_with 'ey' }
      it { expect { Mumukit::Auth::Token.decode token.encode }.to raise_error 'Signature has expired' }
    end
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

  describe 'serialization' do
    let(:token) { Mumukit::Auth::Token.build 'mary@example.com' }
    let(:expired_token) { Mumukit::Auth::Token.build 'mary@example.com', expiration: 1.day.ago.round }

    it("can create empty, replicable token") {  expect(Mumukit::Auth::Token.new.encode).to eq Mumukit::Auth::Token.new.encode }

    it { expect(Mumukit::Auth::Token.load(token.encode).jwt).to eq token.jwt  }
    it { expect(Mumukit::Auth::Token.load(expired_token.encode)).to be nil  }

    it { expect(Mumukit::Auth::Token.dump token).to eq token.encode  }
  end
end
