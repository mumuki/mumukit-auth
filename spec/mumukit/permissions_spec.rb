require 'spec_helper'

def parse_permissions(hash)
  Mumukit::Auth::Permissions.parse hash
end

describe Mumukit::Auth::Permissions do
  let(:permissions) do
    Mumukit::Auth::Permissions.new(
        student: Mumukit::Auth::Scope.parse('foo/*:test/*'),
        owner: Mumukit::Auth::Scope.parse('test/*'),
        teacher: Mumukit::Auth::Scope.parse('foo/baz'))
  end

  describe '#merge' do
    it { expect(Mumukit::Auth::Permissions.new.merge(Mumukit::Auth::Permissions.new)).to json_like({}) }
    it { expect(permissions.merge(Mumukit::Auth::Permissions.new)).to json_like permissions }
    it { expect(Mumukit::Auth::Permissions.new.merge(permissions)).to json_like(permissions) }
    it { expect(permissions.merge(permissions)).to json_like(permissions) }

    it do
      permissions_1 = parse_permissions student: 'foo/*', teacher: 'foo/baz', owner: 'foobar/baz'
      permissions_2 = parse_permissions student: 'foo/baz', teacher: 'foo/*', owner: 'bar/baz'
      expect(permissions_1.merge(permissions_2)).to json_like student: 'foo/*', teacher: 'foo/*', owner: 'foobar/baz:bar/baz'
    end
  end

  describe '#delegate_to?' do
    let(:permissions) do
      parse_permissions(student: 'foo/*', teacher: 'foo/baz', headmaster: '*')
    end


    it { expect(permissions.delegate_to? Mumukit::Auth::Permissions.new).to be true }
    it { expect(permissions.delegate_to? parse_permissions(owner: 'foo/*')).to be false }
    it { expect(permissions.delegate_to? parse_permissions(student: 'foo/*')).to be true }
    it { expect(permissions.delegate_to? parse_permissions(student: 'foo/bar')).to be true }
    it { expect(permissions.delegate_to? parse_permissions(student: 'bar/*')).to be false }
    it { expect(permissions.delegate_to? parse_permissions(student: '*')).to be false }
    it { expect(permissions.delegate_to? parse_permissions(writer: '*')).to be false }
    it { expect(permissions.delegate_to? parse_permissions(headmaster: 'foo/bar')).to be true }
    it { expect(permissions.delegate_to? parse_permissions(headmaster: 'foo/*')).to be true }
  end

  describe 'parsing' do
    it { expect(permissions).to json_like parse_permissions(student: 'foo/*:test/*',
                                                            owner: 'test/*',
                                                            teacher: 'foo/baz') }
    it { expect(permissions).to json_like parse_permissions('student' => 'foo/*:test/*',
                                                            'owner' => 'test/*',
                                                            'teacher' => 'foo/baz') }
  end

  describe 'checking' do
    let(:parsed_permissions) do
      Mumukit::Auth::Permissions.load(permissions.to_json)
    end

    it { expect(permissions.teacher? 'foobar/baz').to be false }
    it { expect(permissions.teacher? 'foobar/_').to be false }

    it { expect(permissions.teacher? Mumukit::Auth::Slug.parse('foo/baz')).to be true }
    it { expect(permissions.teacher? Mumukit::Auth::Slug.parse('foobar/_')).to be false }

    it { expect(permissions.teacher? 'foo/baz').to be true }
    it { expect(permissions.teacher? 'foo/_').to be true }

    it { expect(permissions.owner? 'test/student').to be true }
    it { expect(permissions.owner? 'test/_').to be true }
    it { expect(permissions.owner? 'test/*').to be true }
    it { expect(permissions.owner? '*/*').to be false }

    it { expect(permissions.writer? 'test/student').to be true }
    it { expect(permissions.writer? 'test/_').to be true }

    it { expect(permissions.student? 'foo/bar').to be true }
    it { expect(permissions.student? 'test/student').to be true }
    it { expect(permissions.student? 'foo/student').to be true }
    it { expect(permissions.student? 'baz/student').to be false }
    it { expect(permissions.student? 'baz/_').to be false }

    it { expect(parsed_permissions.student? 'foo/bar').to be true }
    it { expect(parsed_permissions.student? 'test/student').to be true }
    it { expect(parsed_permissions.student? 'foo/student').to be true }
    it { expect(parsed_permissions.student? 'baz/student').to be false }
    it { expect(parsed_permissions.student? 'baz/_').to be false }

    it { expect { parsed_permissions.protect! :student, 'baz/_' }.to raise_error(Mumukit::Auth::UnauthorizedAccessError) }
    it { expect { parsed_permissions.protect! :student, 'foo/student' }.not_to raise_error }
    it { expect { parsed_permissions.protect! :writer, 'foo/student' }.to raise_error(Mumukit::Auth::UnauthorizedAccessError) }
    it { expect { parsed_permissions.protect! :teacher, 'test/_' }.not_to raise_error }
    it { expect { parsed_permissions.protect! :teacher, 'foo/_' }.not_to raise_error }
    it { expect { parsed_permissions.protect! :teacher, 'bar/_' }.to raise_error(Mumukit::Auth::UnauthorizedAccessError) }
  end

  describe 'add_scope!' do
    let(:permissions) { parse_permissions({}) }
    context 'when no teacher permissions added' do
      before { permissions.add_permission!(:teacher, 'test/bar') }

      it { expect(permissions.has_role? :student).to be false }
      it { expect(permissions.has_role? :teacher).to eq true }

      it { expect(permissions.teacher? 'test/bar').to eq true }

      it { expect(permissions.has_permission? :teacher, 'test/bar').to be true }
      it { expect(permissions.has_permission? :teacher, 'test/baz').to be false }

      it { expect(permissions.as_json).to json_like(teacher: 'test/bar') }

      context 'when added broader grant' do
        before { permissions.add_permission! :teacher, 'test/*' }

        it { expect(permissions).to json_like teacher: 'test/*' }
        it { expect(permissions.has_permission? :teacher, 'test/baz').to be true }
      end

    end
    context 'when no student permissions added' do
      before { permissions.add_permission!(:student, 'test/*') }

      it { expect(permissions.has_role? :student).to eq true }
      it { expect(permissions.student? 'test/*').to eq true }

      context 'when added twice' do
        before { permissions.add_permission! :student, 'test/*' }

        it { expect(permissions).to json_like student: 'test/*' }
      end

      context 'when added narrower grant' do
        before { permissions.add_permission! :student, 'test/foo' }

        it { expect(permissions).to json_like student: 'test/*' }
      end
    end
  end

  context 'remove_scope!' do
    let(:permissions) { parse_permissions(student: 'foo/bar:test/*:foo/baz') }

    context 'when permission is present' do
      before { permissions.remove_permission!(:student, 'test/*') }
      it { expect(permissions.student? 'test/*').to eq false }
      it { expect(permissions.student? 'foo/bar').to eq true }
      it { expect(permissions.student? 'foo/baz').to eq true }
    end

    context 'when scope is not present' do
      before { permissions.remove_permission!(:student, 'baz/*') }
      it { expect(permissions.student? 'test/*').to eq true }
      it { expect(permissions.student? 'foo/bar').to eq true }
      it { expect(permissions.student? 'foo/baz').to eq true }
    end

    context 'when role is not present' do
      before { permissions.remove_permission!(:teacher, 'baz/*') }
      it { expect(permissions.student? 'test/*').to eq true }
      it { expect(permissions.student? 'foo/bar').to eq true }
      it { expect(permissions.student? 'foo/baz').to eq true }
    end
  end

  context 'permissions hierarchy' do
    let(:permissions) do
      Mumukit::Auth::Permissions.new(
          headmaster: Mumukit::Auth::Scope.parse('foo/*'),
          owner: Mumukit::Auth::Scope.parse('test/*'))
    end
    it { expect(permissions.student? 'test/*').to eq true }
    it { expect(permissions.teacher? 'foo/bar').to eq true }
    it { expect(permissions.headmaster? 'foo/baz').to eq true }
    it { expect(permissions.headmaster? 'bar/baz').to eq false }
    it { expect(permissions.headmaster? 'test/baz').to eq true }
    it { expect(permissions.owner? 'test/baz').to eq true }

  end

end
