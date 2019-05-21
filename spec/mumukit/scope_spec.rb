require 'spec_helper'

describe Mumukit::Auth::Scope do
  describe 'one grant' do
    let(:scope) { Mumukit::Auth::Scope.parse('*') }

    it { expect(scope.authorizes? 'foo/bar').to be true }
  end

  describe 'two scope' do
    let(:scope) { Mumukit::Auth::Scope.parse('foo/*:mumuki/*') }

    it { expect(scope.authorizes? 'foo/bag').to be true }
    it { expect(scope.authorizes? 'foo/baz').to be true }
    it { expect(scope.authorizes? 'fooz/baz').to be false }
    it { expect(scope.authorizes? 'xfoo/baz').to be false }
    it { expect(scope.authorizes? 'mumuki/funcional').to be true }
    it { expect(scope.authorizes? 'mumuki/logico').to be true }
    it { expect(scope.authorizes? 'Mumuki/Logico').to be true }
  end

  describe 'grant none' do
    let(:scope) { Mumukit::Auth::Scope.parse('') }

    it { expect(scope.authorizes? 'foo/bag').to be false }
    it { expect(scope.authorizes? 'fooz/baz').to be false }
  end
end
