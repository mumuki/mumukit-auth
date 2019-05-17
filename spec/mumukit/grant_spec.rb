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
  end

  describe 'custom grant' do
    class IncludesGrant < Mumukit::Auth::Grant
      def allows?(resource_slug)
        resource_slug.to_mumukit_slug.first.include? 'foo'
      end

      def to_s
        '{includes:foo}'
      end

      def to_mumukit_slug
        Mumukit::Auth::Slug.new '*', '*'
      end

      def self.try_parse(pattern)
        new if pattern =~ /\{includes\:foo\}\/\*/
      end
    end
    before(:all) { Mumukit::Auth::Grant.add_custom_grant_type! IncludesGrant  }
    after(:all) { Mumukit::Auth::Grant.remove_custom_grant_type! IncludesGrant  }

    let(:grant) { Mumukit::Auth::Grant.parse('{includes:foo}/*') }

    it { expect(Mumukit::Auth::Grant.custom_grant_types).to eq [IncludesGrant]}
    it { expect(grant.allows? 'foo/baz').to be true }
    it { expect(grant.allows? 'foobar/baz').to be true }
    it { expect(grant.allows? 'bar/baz').to be false }

  end
end
