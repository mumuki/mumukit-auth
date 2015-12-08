require 'spec_helper'

describe Mumukit::Auth::Permissions do
  describe 'one grant' do
    let(:permissions) { Mumukit::Auth::Permissions.parse('*') }

    it { expect(permissions.allows? 'foo/bar').to be true }
  end

  describe 'two grants' do
    let(:permissions) { Mumukit::Auth::Permissions.parse('foo/*:mumuki/*') }

    it { expect(permissions.allows? 'foo/bag').to be true }
    it { expect(permissions.allows? 'foo/baz').to be true }
    it { expect(permissions.allows? 'fooz/baz').to be false }
    it { expect(permissions.allows? 'xfoo/baz').to be false }
    it { expect(permissions.allows? 'mumuki/funcional').to be true }
    it { expect(permissions.allows? 'mumuki/logico').to be true }

    it { expect { permissions.protect! 'baz/funcional' }.to raise_error(Mumukit::Auth::UnauthorizedAccessError) }
    it { expect { permissions.protect! 'mumuki/logico' }.not_to raise_error(Mumukit::Auth::UnauthorizedAccessError) }
  end

  describe 'grant none' do
    let(:permissions) { Mumukit::Auth::Permissions.parse('') }

    it { expect(permissions.allows? 'foo/bag').to be false }
    it { expect(permissions.allows? 'fooz/baz').to be false }
  end
end
