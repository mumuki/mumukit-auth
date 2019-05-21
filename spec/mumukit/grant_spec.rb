require 'spec_helper'

describe Mumukit::Auth::Grant do
  describe 'to_s' do
    it { expect('Foo/*'.to_mumukit_grant.to_s).to eq  'foo/*' }
    it { expect('*'.to_mumukit_grant.to_s).to eq  '*' }
    it { expect('Foo/Bar'.to_mumukit_grant.to_s).to eq  'foo/bar' }
  end

  describe 'compare' do
    it { expect('foo/baz'.to_mumukit_grant).to eq  'foo/baz'.to_mumukit_grant }
    it { expect('FOO/BAZ'.to_mumukit_grant).to eq  'foo/baz'.to_mumukit_grant }
    it { expect('Foo/Baz'.to_mumukit_grant).to eq  'FOO/BAZ'.to_mumukit_grant }
    it { expect('Foo/*'.to_mumukit_grant).to eq  'FOO/*'.to_mumukit_grant }

    it { expect('*'.to_mumukit_grant == '*'.to_mumukit_grant).to be true }
    it { expect('*'.to_mumukit_grant.eql? '*'.to_mumukit_grant).to be true }
    it { expect('*'.to_mumukit_grant.hash == '*'.to_mumukit_grant.hash).to be true }

    it { expect('foo/*'.to_mumukit_grant == 'foo/*'.to_mumukit_grant).to be true }
    it { expect('foo/*'.to_mumukit_grant.eql? 'foo/*'.to_mumukit_grant).to be true }
    it { expect('foo/*'.to_mumukit_grant.hash == 'foo/*'.to_mumukit_grant.hash).to be true }

    it { expect('foo/bar'.to_mumukit_grant == 'foo/bar'.to_mumukit_grant).to be true }
    it { expect('foo/bar'.to_mumukit_grant.eql? 'foo/bar'.to_mumukit_grant).to be true }
    it { expect('foo/bar'.to_mumukit_grant.hash == 'foo/bar'.to_mumukit_grant.hash).to be true }

    it { expect('foo/bar'.to_mumukit_grant == 'foo/*'.to_mumukit_grant).to be false }
    it { expect('foo/bar'.to_mumukit_grant.eql? 'foo/*'.to_mumukit_grant).to be false }
    it { expect('foo/bar'.to_mumukit_grant.hash == 'foo/*'.to_mumukit_grant.hash).to be false }
  end

  describe 'grant all' do
    let(:grant) { Mumukit::Auth::Grant.parse('*') }

    it { expect(grant.allows? '_/_').to be true }

    it { expect(grant.allows? 'foo/_').to be true }

    it { expect(grant.allows? 'foo/bar').to be true }
    it { expect(grant.allows? 'Foo/Bar').to be true }

  end

  describe 'expanded grant all' do
    let(:grant) { Mumukit::Auth::Grant.parse('*/*') }

    it { expect(grant.allows? '_/_').to be true }

    it { expect(grant.allows? 'foo/_').to be true }
    it { expect(grant.allows? 'foo/bar').to be true }
    it { expect(grant.allows? 'FOO/BAR').to be true }

    it { expect(grant.to_s).to eq '*' }
  end

  describe 'grant org' do
    let(:grant) { Mumukit::Auth::Grant.parse('foo/*') }

    it { expect(grant.allows? '_/_').to be true }

    it { expect(grant.allows? 'foo/_').to be true }
    it { expect(grant.allows? 'FOO/Bar').to be true }

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

    it { expect(grant.allows? 'FOO/BAR').to be true }
    it { expect(Mumukit::Auth::Grant.parse('FOO/Bar').allows? 'foo/BAR').to be true }

    xit { expect('foo/bar'.to_mumukit_grant.includes? '*/*').to raise_error('invalid slug') }
    xit { expect('foo/bar'.to_mumukit_grant.includes? '*').to raise_error('invalid slug') }
  end

  describe 'includes?' do
    it { expect('foo/bar'.to_mumukit_grant.includes? 'foo/bar').to be true }
    it { expect('foo/*'.to_mumukit_grant.includes? 'foo/*').to be true }
    it { expect('foo/*'.to_mumukit_grant.includes? 'foo/bar').to be true }
    it { expect('foo/bar'.to_mumukit_grant.includes? 'foo/*').to be false }
    it { expect('*'.to_mumukit_grant.includes? 'foo/bar').to be true }
    it { expect('foo/bar'.to_mumukit_grant.includes? '*').to be false }
    xit { expect('foo/bar'.to_mumukit_grant.includes? '_/_').to raise_error('invalid grant') }
  end

  describe 'custom grant' do
    class IncludesGrant < Mumukit::Auth::Grant::Base
      def allows?(slug_like)
        slug_like.to_mumukit_slug.first.include? 'foo'
      end

      def to_s
        '{includesFoo}'
      end

      def self.try_parse(pattern)
        new if pattern =~ /\{includesFoo\}/
      end
    end
    before(:all) { Mumukit::Auth::Grant.add_custom_grant_type! IncludesGrant  }
    after(:all) { Mumukit::Auth::Grant.remove_custom_grant_type! IncludesGrant  }

    let(:grant) { Mumukit::Auth::Grant.parse('{includesFoo}') }

    it { expect(Mumukit::Auth::Grant.custom_grant_types).to eq [IncludesGrant]}
    it { expect(grant.allows? 'foo/baz').to be true }
    it { expect(grant.allows? 'foobar/baz').to be true }
    it { expect(grant.allows? 'bar/baz').to be false }

    it { expect(grant.includes? 'foo/baz').to be false }
    it { expect(grant.includes? 'foobar/baz').to be false }
    it { expect(grant.includes? 'bar/baz').to be false }

    it { expect(grant.includes? '{includesFoo}').to be true }
  end
end
