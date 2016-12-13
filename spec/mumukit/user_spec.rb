require 'spec_helper'

describe Mumukit::Auth::User do
  let(:user) do
    Mumukit::Auth::User.new(
        'foo@bar.com',
        [Mumukit::Auth::Permission.parse(student: 'foo/*:test/*'),
         Mumukit::Auth::Permission.parse(admin: 'test/*'),
         Mumukit::Auth::Permission.parse(classroom: 'foo/baz')])
  end

  it { expect(user.teacher? 'foobar/baz').to be false }
  it { expect(user.teacher? 'foobar').to be false }

  it { expect(user.teacher? 'foo/baz').to be true }
  it { expect(user.teacher? 'foo').to be true }

  it { expect(user.admin? 'test/atheneum').to be true }
  it { expect(user.admin? 'test').to be true }

  it { expect(user.librarian? 'test/atheneum').to be false }
  it { expect(user.librarian? 'test').to be false }

  it { expect(user.student? 'test/atheneum').to be true }
  it { expect(user.student? 'test').to be true }
  it { expect(user.student? 'foo/atheneum').to be true }
  it { expect(user.student? 'foo').to be true }
  it { expect(user.student? 'baz/atheneum').to be false }
  it { expect(user.student? 'baz').to be false }

  it { expect(Mumukit::Auth::Token.from_env({}).user.student? 'foo/bar').to be false }

  context 'when no permissions' do
    let(:user) { Mumukit::Auth::User.new('foo@bar.com') }
    before { user.add_permission! 'atheneum', 'test/*' }

    it { expect(user.as_json).to json_like(uid: 'foo@bar.com',
                                           permissions: {atheneum: 'test}/*'}) }
    it { expect(user.has_role? :atheneum, 'test/baz').to be_true }
  end

  context 'add_permission!' do
    let(:user) { Mumukit::Auth::Metadata.new({atheneum: {scopes: 'foo/bar'}}.deep_stringify_keys) }
    context 'when no permissions added' do
      before { user.add_permission!('classroom', 'test/*') }
      it { expect(user.teacher? 'test/*').to eq true }
    end
    context 'when no permissions added' do
      before { user.add_permission!('atheneum', 'test/*') }
      it { expect(user.student? 'test/*').to eq true }
    end
  end

  context 'remove_permission!' do
    let(:user) { Mumukit::Auth::Metadata.new({atheneum: {scopes: 'foo/bar:test/*:foo/baz'}}.deep_stringify_keys) }
    before { user.remove_permission!('atheneum', 'test/*') }
    it { expect(user.student? 'test/*').to eq false }
    it { expect(user.student? 'foo/bar').to eq true }
    it { expect(user.student? 'foo/baz').to eq true }
  end
end
