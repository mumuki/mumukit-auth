require 'spec_helper'

describe Mumukit::Auth::Scope do
  describe 'one grant' do
    let(:scope) { Mumukit::Auth::Scope.parse('*') }

    it { expect(scope.allows? 'foo/bar').to be true }
  end

  describe 'two scope' do
    let(:scope) { Mumukit::Auth::Scope.parse('foo/*:mumuki/*') }

    it { expect(scope.allows? 'foo/bag').to be true }
    it { expect(scope.allows? 'foo/baz').to be true }
    it { expect(scope.allows? 'fooz/baz').to be false }
    it { expect(scope.allows? 'xfoo/baz').to be false }
    it { expect(scope.allows? 'mumuki/funcional').to be true }
    it { expect(scope.allows? 'mumuki/logico').to be true }
    it { expect(scope.allows? 'Mumuki/Logico').to be true }
  end

  describe 'grant none' do
    let(:scope) { Mumukit::Auth::Scope.parse('') }

    it { expect(scope.allows? 'foo/bag').to be false }
    it { expect(scope.allows? 'fooz/baz').to be false }
  end
end
