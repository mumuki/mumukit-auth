require 'spec_helper'

describe Mumukit::Auth::Grant do
  describe 'grant all' do
    let(:grant) { Mumukit::Auth::Grant.parse('*') }

    it { expect(grant.allows? '_/_').to be true }

    it { expect(grant.allows? 'foo/_').to be true }

    it { expect(grant.allows? 'foo/bar').to be true }

  end

  describe 'expanded grant all' do
    let(:grant) { Mumukit::Auth::Grant.parse('*/*') }

    it { expect(grant.allows? '_/_').to be true }

    it { expect(grant.allows? 'foo/_').to be true }
    it { expect(grant.allows? 'foo/bar').to be true }

    it { expect(grant.to_s).to eq '*' }
  end

  describe 'grant org' do
    let(:grant) { Mumukit::Auth::Grant.parse('foo/*') }

    it { expect(grant.allows? '_/_').to be true }

    it { expect(grant.allows? 'foo/_').to be true }

    it { expect(grant.allows? 'fooz/_').to be false }
    it { expect(grant.allows? 'xfoo/_').to be false }

    it { expect(grant.allows? 'foo/bag').to be true }
    it { expect(grant.allows? 'foo/baz').to be true }
    it { expect(grant.allows? 'fooz/baz').to be false }
    it { expect(grant.allows? 'xfoo/baz').to be false }
  end

  describe 'grant one' do
    let(:grant) { Mumukit::Auth::Grant.parse('foo/bar') }

    it { expect(grant.allows? '_/_').to be true }

    it { expect(grant.allows? 'foo/_').to be true }

    it { expect(grant.allows? 'fooz/_').to be false }
    it { expect(grant.allows? 'xfoo/_').to be false }

    it { expect(grant.allows? 'foo/bag').to be false }
    it { expect(grant.allows? 'foo/bar').to be true }
    it { expect(grant.allows? 'fooz/baz').to be false }
  end

end
