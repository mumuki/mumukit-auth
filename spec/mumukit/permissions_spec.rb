require 'spec_helper'

describe Mumukit::Auth::Permissions do
  let(:permissions) do
    Mumukit::Auth::Permissions.new(
        student: Mumukit::Auth::Scope.parse('foo/*:test/*'),
        owner: Mumukit::Auth::Scope.parse('test/*'),
        teacher: Mumukit::Auth::Scope.parse('foo/baz'))
  end

  it { expect(permissions).to json_like Mumukit::Auth::Permissions.parse(student: 'foo/*:test/*',
                                                                         owner: 'test/*',
                                                                         teacher: 'foo/baz') }
  it { expect(permissions).to json_like Mumukit::Auth::Permissions.parse('student' => 'foo/*:test/*',
                                                                         'owner' => 'test/*',
                                                                         'teacher' => 'foo/baz') }
  it { expect(permissions.teacher? 'foobar/baz').to be false }
  it { expect(permissions.teacher? 'foobar/_').to be false }

  it { expect(permissions.teacher? Mumukit::Auth::Slug.parse('foo/baz')).to be true }
  it { expect(permissions.teacher? Mumukit::Auth::Slug.parse('foobar/_')).to be false }

  it { expect(permissions.teacher? 'foo/baz').to be true }
  it { expect(permissions.teacher? 'foo/_').to be true }

  it { expect(permissions.owner? 'test/student').to be true }
  it { expect(permissions.owner? 'test/_').to be true }

  it { expect(permissions.writer? 'test/student').to be false }
  it { expect(permissions.writer? 'test/_').to be false }

  it { expect(permissions.student? 'foo/bar').to be true }
  it { expect(permissions.student? 'test/student').to be true }
  it { expect(permissions.student? 'foo/student').to be true }
  it { expect(permissions.student? 'baz/student').to be false }
  it { expect(permissions.student? 'baz/_').to be false }

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

end
