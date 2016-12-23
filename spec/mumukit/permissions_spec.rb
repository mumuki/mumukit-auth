require 'spec_helper'

describe Mumukit::Auth::Permissions do
  let(:permissions) do
    Mumukit::Auth::Permissions.new(
        student: Mumukit::Auth::Scope.parse('foo/*:test/*'),
        owner: Mumukit::Auth::Scope.parse('test/*'),
        teacher: Mumukit::Auth::Scope.parse('foo/baz'))
  end

  describe '#delegate_to?' do
    let(:permissions) do
      Mumukit::Auth::Permissions.parse(student: 'foo/*', teacher: 'foo/baz', headmaster: '*')
    end


    it { expect(permissions.delegate_to? Mumukit::Auth::Permissions.new).to be true }
    it { expect(permissions.delegate_to? Mumukit::Auth::Permissions.parse(owner: 'foo/*')).to be false }
    it { expect(permissions.delegate_to? Mumukit::Auth::Permissions.parse(student: 'foo/*')).to be true }
    it { expect(permissions.delegate_to? Mumukit::Auth::Permissions.parse(student: 'foo/bar')).to be true }
    it { expect(permissions.delegate_to? Mumukit::Auth::Permissions.parse(student: 'bar/*')).to be false }
    it { expect(permissions.delegate_to? Mumukit::Auth::Permissions.parse(student: '*')).to be false }
    it { expect(permissions.delegate_to? Mumukit::Auth::Permissions.parse(writer: '*')).to be false }
    it { expect(permissions.delegate_to? Mumukit::Auth::Permissions.parse(headmaster: 'foo/bar')).to be true }
    it { expect(permissions.delegate_to? Mumukit::Auth::Permissions.parse(headmaster: 'foo/*')).to be true }
  end

  describe 'parsing' do
    it { expect(permissions).to json_like Mumukit::Auth::Permissions.parse(student: 'foo/*:test/*',
                                                                           owner: 'test/*',
                                                                           teacher: 'foo/baz') }
    it { expect(permissions).to json_like Mumukit::Auth::Permissions.parse('student' => 'foo/*:test/*',
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
  end
  context 'when no permissions' do
    let(:permissions) { Mumukit::Auth::Permissions.parse({}) }

    before { permissions.add_permission! :student, 'test/*' }

    it { expect(permissions.as_json).to json_like(student: 'test/*') }
    it { expect(permissions.has_permission? :student, 'test/baz').to be true }
    it { expect(permissions.has_role? :student).to be true }
  end

  context 'add_scope!' do
    let(:permissions) { Mumukit::Auth::Permissions.parse(student: 'foo/bar') }
    context 'when no permissions added' do
      before { permissions.add_permission!(:teacher, 'test/*') }

      it { expect(permissions.has_role? :teacher).to eq true }
      it { expect(permissions.teacher? 'test/*').to eq true }

    end
    context 'when no permissions added' do
      before { permissions.add_permission!(:student, 'test/*') }

      it { expect(permissions.has_role? :student).to eq true }
      it { expect(permissions.student? 'test/*').to eq true }
    end
  end

  context 'remove_scope!' do
    let(:permissions) { Mumukit::Auth::Permissions.parse(student: 'foo/bar:test/*:foo/baz') }

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
