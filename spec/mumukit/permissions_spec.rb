require 'spec_helper'

def parse_permissions(hash)
  Mumukit::Auth::Permissions.parse hash
end

describe Mumukit::Auth::Permissions do
  let(:permissions) do
    Mumukit::Auth::Permissions.new(
        student: Mumukit::Auth::Scope.parse('foo/*:test/*'),
        teacher: Mumukit::Auth::Scope.parse('foo/baz'))
  end

  describe '#parse' do
    it { expect(Mumukit::Auth::Permissions.parse(nil)).to be_empty }
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
      parse_permissions(student: 'foo/*', teacher: 'foo/baz:test/foo', headmaster: '*', janitor: 'test/bar')
    end


    it { expect(permissions.delegate_to? Mumukit::Auth::Permissions.new).to be true }
    it { expect(permissions.delegate_to? parse_permissions(owner: 'foo/*')).to be false }
    it { expect(permissions.delegate_to? parse_permissions(student: 'foo/*')).to be true }
    it { expect(permissions.delegate_to? parse_permissions(student: 'foo/bar')).to be true }
    it { expect(permissions.delegate_to? parse_permissions(student: 'bar/*')).to be true }
    it { expect(permissions.delegate_to? parse_permissions(student: '*')).to be true }
    it { expect(permissions.delegate_to? parse_permissions(writer: '*')).to be false }
    it { expect(permissions.delegate_to? parse_permissions(headmaster: 'foo/bar')).to be true }
    it { expect(permissions.delegate_to? parse_permissions(headmaster: 'foo/*')).to be true }


    it { expect(permissions.delegate_to? parse_permissions(student: 'test/foo')).to be true }
    it { expect(permissions.delegate_to? parse_permissions(teacher: 'test/bar')).to be true }
    it { expect(permissions.delegate_to? parse_permissions(headmaster: 'test/bar')).to be true }

  end

  describe '.reparse' do
    it { expect(Mumukit::Auth::Permissions.reparse(permissions)).to eq permissions }
    it { expect(Mumukit::Auth::Permissions.reparse(permissions).scopes).to eq permissions.scopes }
  end

  describe 'to_s' do
    it { expect(Mumukit::Auth::Permissions.new.to_s).to eq '!' }
    it { expect(permissions.to_s).to eq '!student:foo/*:test/*;teacher:foo/baz' }
  end

  describe '#assign_to?' do
    let(:blank_permissions) { Mumukit::Auth::Permissions.new }

    context 'without changing permissions' do
      it { expect(blank_permissions.assign_to?(permissions, permissions)).to be true }
      it { expect { blank_permissions.protect_permissions_assignment! permissions, permissions }.to_not raise_error }
    end

    context 'adding permissions' do
      it { expect(permissions.assign_to?(parse_permissions(student: 'foo/*'), blank_permissions)).to be true }
      it { expect(blank_permissions.assign_to?(permissions, blank_permissions)).to be false }
      it { expect { blank_permissions.protect_permissions_assignment! permissions, blank_permissions }.to raise_error(Mumukit::Auth::UnauthorizedAccessError) }

    end

    context 'removing permissions' do
      it { expect(permissions.assign_to?(blank_permissions, parse_permissions(student: 'foo/*'))).to be true }
      it { expect(blank_permissions.assign_to?(blank_permissions, permissions)).to be false }
    end
  end

  describe 'parsing' do
    it { expect(permissions).to json_like parse_permissions(student: 'foo/*:test/*',
                                                            teacher: 'foo/baz') }
    it { expect(permissions).to json_like parse_permissions('student' => 'foo/*:test/*',
                                                            'teacher' => 'foo/baz') }
  end

  describe 'checking' do
    let(:parsed_permissions) do
      Mumukit::Auth::Permissions.load(permissions.to_json)
    end

    describe 'non-admin permissions' do
      let(:permissions) { parse_permissions(ex_student: 'baz/student:test/student', student: 'foo/*:test/*', teacher: 'foo/baz', writer: 'test/student') }

      it { expect(permissions.teacher? 'foobar/baz').to be false }
      it { expect(permissions.teacher? 'foobar/_').to be false }

      it { expect(permissions.teacher? Mumukit::Auth::Slug.parse('foo/baz')).to be true }
      it { expect(permissions.teacher? Mumukit::Auth::Slug.parse('foobar/_')).to be false }

      it { expect(permissions.teacher? 'foo/baz').to be true }
      it { expect(permissions.teacher? 'foo/_').to be true }

      it { expect(permissions.admin?).to be false }
      it { expect(permissions.owner?).to be false }

      it { expect(permissions.writer? 'test/student').to be true }
      it { expect(permissions.writer? 'test/_').to be true }
      it { expect(permissions.writer? 'other/_').to be false }

      it { expect(permissions.student?).to be true }
      it { expect(permissions.student? '_/_').to be true }
      it { expect(permissions.student? 'foo/bar').to be true }
      it { expect(permissions.student? 'test/student').to be true }
      it { expect(permissions.student? 'foo/student').to be true }
      it { expect(permissions.student? 'baz/student').to be false }
      it { expect(permissions.student? 'baz/_').to be false }

      it { expect(permissions.ex_student?).to be true }
      it { expect(permissions.ex_student? '_/_').to be true }
      it { expect(permissions.ex_student? 'foo/bar').to be true }
      it { expect(permissions.ex_student? 'test/student').to be true }
      it { expect(permissions.ex_student? 'foo/student').to be true }
      it { expect(permissions.ex_student? 'bar/student').to be false }
      it { expect(permissions.ex_student? 'bar/_').to be false }
      it { expect(permissions.ex_student? 'baz/student').to be true }
      it { expect(permissions.ex_student? 'baz/_').to be true }

      it { expect(parsed_permissions.student? 'foo/bar').to be true }
      it { expect(parsed_permissions.student? 'test/student').to be true }
      it { expect(parsed_permissions.student? 'foo/student').to be true }
      it { expect(parsed_permissions.student? 'baz/student').to be false }
      it { expect(parsed_permissions.student? 'baz/_').to be false }

      it { expect { parsed_permissions.protect! :ex_student, 'baz/_' }.not_to raise_error }
      it { expect { parsed_permissions.protect! :ex_student, 'bar/_' }.to raise_error(Mumukit::Auth::UnauthorizedAccessError) }
      it { expect { parsed_permissions.protect! :student, 'baz/_' }.to raise_error(Mumukit::Auth::UnauthorizedAccessError) }
      it { expect { parsed_permissions.protect! :student, 'foo/student' }.not_to raise_error }
      it { expect { parsed_permissions.protect! :writer, 'foo/student' }.to raise_error(Mumukit::Auth::UnauthorizedAccessError) }
      it { expect { parsed_permissions.protect! :teacher, 'test/_' }.to raise_error }
      it { expect { parsed_permissions.protect! :teacher, 'foo/_' }.not_to raise_error }
      it { expect { parsed_permissions.protect! :teacher, 'bar/_' }.to raise_error(Mumukit::Auth::UnauthorizedAccessError) }
      it { expect { parsed_permissions.protect! :teacher, 'bar/_' }.to raise_error('Unauthorized access to bar/_ as teacher. Scope is `foo/baz`') }
    end

    describe 'owner permissions' do
      let(:permissions) { parse_permissions(owner: '*') }

      it { expect(permissions.admin?).to be true }

      it { expect(permissions.owner?).to be true }
      it { expect(permissions.owner? 'test/student').to be true }
      it { expect(permissions.owner? 'test/_').to be true }
      it { expect(permissions.owner? 'test/*').to be true }
      it { expect(permissions.owner? '*/*').to be true }

      it { expect(permissions.writer? 'test/_').to be true }

      it { expect { parsed_permissions.protect! :teacher, 'test/_' }.not_to raise_error }
    end

    describe 'admin permissions' do
      let(:permissions) { parse_permissions(admin: '*') }

      it { expect(permissions.owner?).to be false }

      it { expect(permissions.admin?).to be true }
      it { expect(permissions.admin? 'test/student').to be true }
      it { expect(permissions.admin? 'test/_').to be true }
      it { expect(permissions.admin? 'test/*').to be true }
      it { expect(permissions.admin? '*/*').to be true }

      it { expect(permissions.writer? 'test/_').to be true }

      it { expect { parsed_permissions.protect! :teacher, 'test/_' }.not_to raise_error }
    end
  end

  describe '#grants_for' do
    it { expect(Mumukit::Auth::Permissions.parse(student: 'foo/bar:baz/goo').grant_strings_for :student).to eq ['foo/bar', 'baz/goo'] }
  end

  describe 'add_permission!' do
    let(:permissions) { parse_permissions({}) }

    context 'when student and then teacher permissions added' do
      before { permissions.add_permission!(:student, 'test/bar') }
      before { permissions.add_permission!(:teacher, 'test/bar') }

      it { expect(permissions.has_role? :student).to be false }
      it { expect(permissions.has_role? :teacher).to eq true }

      it { expect(permissions.teacher? 'test/bar').to eq true }
    end

    context 'when teacher and then student permissions added' do
      before { permissions.add_permission!(:teacher, 'test/bar') }
      before { permissions.add_permission!(:student, 'test/bar') }

      it { expect(permissions.has_role? :student).to be false }
      it { expect(permissions.has_role? :teacher).to eq true }

      it { expect(permissions.teacher? 'test/bar').to eq true }
    end

    context 'when teacher permissions added' do
      before { permissions.add_permission!(:teacher, 'test/bar') }

      it { expect(permissions.has_role? :student).to be false }
      it { expect(permissions.has_role? :teacher).to eq true }

      it { expect(permissions.teacher? 'test/bar').to eq true }

      it { expect(permissions.has_permission? :teacher, 'test/bar').to be true }
      it { expect(permissions.has_permission? :teacher, 'Test/Bar').to be true }
      it { expect(permissions.has_permission? :teacher, 'test/baz').to be false }

      it { expect(permissions.as_json).to json_like(teacher: 'test/bar') }

      context 'when added broader grant' do
        before { permissions.add_permission! :teacher, 'test/*' }

        it { expect(permissions).to json_like teacher: 'test/*' }
        it { expect(permissions.has_permission? :teacher, 'test/baz').to be true }
      end

      context 'when added broader grant with upcase' do
        before { permissions.add_permission! :teacher, 'Test/*' }

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

  describe '#student_granted_organizations' do
    context 'when there is one organization' do
      let(:permissions) { parse_permissions student: 'pdep/*' }
      it { expect(permissions.student_granted_organizations.size).to eq 1 }
    end
    context 'when there are granted organization with other roles' do
      let(:permissions) { parse_permissions student: 'pdep/*', teacher: 'alcal/*' }
      it { expect(permissions.student_granted_organizations.size).to eq 1 }
    end
    context 'when there are two organizations' do
      let(:permissions) { parse_permissions student: 'pdep/*:alcal/*' }
      it { expect(permissions.student_granted_organizations.size).to eq 2 }
    end
    context 'when all grant present organizations' do
      let(:permissions) { parse_permissions student: 'pdep/*:*' }
      it { expect(permissions.student_granted_organizations.size).to eq 1 }
    end
    context 'when one organization appears twice' do
      let(:permissions) { parse_permissions student: 'pdep/*:pdep/*' }
      it { expect(permissions.student_granted_organizations.size).to eq 1 }
    end
  end

  describe '#any_granted_organizations' do
    context 'when there is one organization' do
      let(:permissions) { parse_permissions student: 'pdep/*' }
      it { expect(permissions.any_granted_organizations.size).to eq 1 }
      it { expect(permissions.any_granted_organizations).to eq Set['pdep'] }
    end
    context 'when there are granted organization with other roles' do
      let(:permissions) { parse_permissions student: 'pdep/*', teacher: 'alcal/*' }
      it { expect(permissions.any_granted_organizations.size).to eq 2 }
      it { expect(permissions.any_granted_organizations).to eq Set['pdep', 'alcal'] }
    end
    context 'when there are two organizations' do
      let(:permissions) { parse_permissions student: 'pdep/*:alcal/*' }
      it { expect(permissions.any_granted_organizations.size).to eq 2 }
      it { expect(permissions.any_granted_organizations).to eq Set['pdep', 'alcal'] }
    end
    context 'when all grant present organizations' do
      let(:permissions) { parse_permissions student: 'pdep/*:*' }
      it { expect(permissions.any_granted_organizations.size).to eq 1 }
      it { expect(permissions.any_granted_organizations).to eq Set['*'] }
    end
    context 'when one organization appears twice' do
      let(:permissions) { parse_permissions student: 'pdep/*:pdep/*' }
      it { expect(permissions.any_granted_organizations.size).to eq 1 }
      it { expect(permissions.any_granted_organizations).to eq Set['pdep'] }
    end
  end

  describe '#any_granted_roles' do
    context 'when there is one role' do
      let(:permissions) { parse_permissions student: 'pdep/*' }
      it { expect(permissions.any_granted_roles.size).to eq 1 }
      it { expect(permissions.any_granted_roles).to eq Set['student'] }
    end
    context 'when there are two granted roles with different organizations' do
      let(:permissions) { parse_permissions student: 'pdep/*', teacher: 'alcal/*' }
      it { expect(permissions.any_granted_roles.size).to eq 2 }
      it { expect(permissions.any_granted_roles).to eq Set['student', 'teacher'] }
    end
    context 'when there is one role with two organizations' do
      let(:permissions) { parse_permissions student: 'pdep/*:alcal/*' }
      it { expect(permissions.any_granted_roles.size).to eq 1 }
      it { expect(permissions.any_granted_roles).to eq Set['student'] }
    end
    context 'when there are several grants' do
      let(:permissions) { parse_permissions student: 'pdep/*:*', teacher: 'alcal/*', owner: 'other/*' }
      it { expect(permissions.any_granted_roles.size).to eq 3 }
      it { expect(permissions.any_granted_roles).to eq Set['student', 'teacher', 'owner'] }
    end
  end

  describe 'remove_permission!' do
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
    it { expect(permissions.headmaster? 'Test/baz').to eq true }
    it { expect(permissions.owner? 'test/baz').to eq true }

  end

end
