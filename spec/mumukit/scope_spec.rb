require 'spec_helper'

describe Mumukit::Auth::Scope do
  describe 'one grant' do
    let(:scope) { Mumukit::Auth::Scope.parse(:student, '*') }

    it { expect(scope.allows? 'foo/bar').to be true }
  end

  describe 'two scope' do
    let(:scope) { Mumukit::Auth::Scope.parse(:student, 'foo/*:mumuki/*') }

    it { expect(scope.allows? 'foo/bag').to be true }
    it { expect(scope.allows? 'foo/baz').to be true }
    it { expect(scope.allows? 'fooz/baz').to be false }
    it { expect(scope.allows? 'xfoo/baz').to be false }
    it { expect(scope.allows? 'mumuki/funcional').to be true }
    it { expect(scope.allows? 'mumuki/logico').to be true }

    it { expect { scope.protect! 'baz/funcional' }.to raise_error(Mumukit::Auth::UnauthorizedAccessError) }
    it { expect { scope.protect! 'mumuki/logico' }.not_to raise_error }
  end

  describe 'grant none' do
    let(:scope) { Mumukit::Auth::Scope.parse(:student) }

    it { expect(scope.allows? 'foo/bag').to be false }
    it { expect(scope.allows? 'fooz/baz').to be false }
  end
end
