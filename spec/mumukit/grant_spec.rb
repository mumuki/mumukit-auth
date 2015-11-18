require 'spec_helper'

describe Mumukit::Auth::Grant do
  describe 'grant all' do
    let(:grant) { Mumukit::Auth::Grant.new('*') }

    it { expect(grant.allows? 'foo/bar').to be true }
  end

  describe 'grant org' do
    let(:grant) { Mumukit::Auth::Grant.new('foo/*') }

    it { expect(grant.allows? 'foo/bag').to be true }
    it { expect(grant.allows? 'foo/baz').to be true }
    it { expect(grant.allows? 'fooz/baz').to be false }
    it { expect(grant.allows? 'xfoo/baz').to be false }
  end

  describe 'grant one' do
    let(:grant) { Mumukit::Auth::Grant.new('foo/bar') }

    it { expect(grant.allows? 'foo/bag').to be false }
    it { expect(grant.allows? 'foo/bar').to be true }
    it { expect(grant.allows? 'fooz/baz').to be false }
  end
end