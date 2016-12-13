require 'spec_helper'

describe Mumukit::Auth::Permissions do
  let(:permissions) do
    Mumukit::Auth::Permissions.new(student: Mumukit::Auth::Scope.parse('foo/*:test/*'),
                                   admin: Mumukit::Auth::Scope.parse('test/*'),
                                   classroom: Mumukit::Auth::Scope.parse('foo/baz'))
  end

  it { expect(permissions).to json_like Mumukit::Auth::Permissions.parse(student: 'foo/*:test/*',
                                                                         admin: 'test/*',
                                                                         classroom: 'foo/baz') }
  it { expect(permissions).to json_like Mumukit::Auth::Permissions.parse('student' => 'foo/*:test/*',
                                                                         'admin' => 'test/*',
                                                                         'classroom' => 'foo/baz') }
  it { expect(permissions.teacher? 'foobar/baz').to be false }
  it { expect(permissions.teacher? 'foobar').to be false }

  it { expect(permissions.teacher? 'foo/baz').to be true }
  it { expect(permissions.teacher? 'foo').to be true }

  it { expect(permissions.owner? 'test/atheneum').to be true }
  it { expect(permissions.owner? 'test').to be true }

  it { expect(permissions.writer? 'test/atheneum').to be false }
  it { expect(permissions.writer? 'test').to be false }

  it { expect(permissions.student? 'test/atheneum').to be true }
  it { expect(permissions.student? 'test').to be true }
  it { expect(permissions.student? 'foo/atheneum').to be true }
  it { expect(permissions.student? 'foo').to be true }
  it { expect(permissions.student? 'baz/atheneum').to be false }
  it { expect(permissions.student? 'baz').to be false }

  it { expect(Mumukit::Auth::Token.from_env({}).permissions.student? 'foo/bar').to be false }

  context 'when no permissions' do
    let(:permissions) { Mumukit::Auth::Permissions.parse({}) }
    before { permissions.add_scope! 'atheneum', 'test/*' }

    it { expect(permissions.as_json).to json_like(atheneum: 'test}/*') }
    it { expect(permissions.has_role? :atheneum, 'test/baz').to be_true }
  end

  context 'add_scope!' do
    let(:permissions) { Mumukit::Auth::Permissions.parse(atheneum: 'foo/bar') }
    context 'when no permissions added' do
      before { permissions.add_scope!('classroom', 'test/*') }
      it { expect(permissions.teacher? 'test/*').to eq true }
    end
    context 'when no permissions added' do
      before { permissions.add_scope!('atheneum', 'test/*') }
      it { expect(permissions.student? 'test/*').to eq true }
    end
  end

  context 'remove_scope!' do
    let(:permissions) { Mumukit::Auth::Permissions.parse(atheneum: 'foo/bar:test/*:foo/baz') }
    before { permissions.remove_scope!('atheneum', 'test/*') }
    it { expect(permissions.student? 'test/*').to eq false }
    it { expect(permissions.student? 'foo/bar').to eq true }
    it { expect(permissions.student? 'foo/baz').to eq true }
  end
end
