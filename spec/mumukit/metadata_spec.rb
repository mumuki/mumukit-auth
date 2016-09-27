require 'spec_helper'

describe Mumukit::Auth::Metadata do
  let(:metadata) do
    Mumukit::Auth::Metadata.new(
        {atheneum: {permissions: 'foo/*:test/*'},
         admin: {permissions: 'test/*'},
         classroom: {permissions: 'foo/baz'}}.deep_stringify_keys)
  end

  it { expect(metadata.teacher? 'foobar/baz').to be false }
  it { expect(metadata.teacher? 'foobar').to be false }

  it { expect(metadata.teacher? 'foo/baz').to be true }
  it { expect(metadata.teacher? 'foo').to be true }

  it { expect(metadata.admin? 'test/atheneum').to be true }
  it { expect(metadata.admin? 'test').to be true }

  it { expect(metadata.librarian? 'test/atheneum').to be false }
  it { expect(metadata.librarian? 'test').to be false }

  it { expect(metadata.student? 'test/atheneum').to be true }
  it { expect(metadata.student? 'test').to be true }
  it { expect(metadata.student? 'foo/atheneum').to be true }
  it { expect(metadata.student? 'foo').to be true }
  it { expect(metadata.student? 'baz/atheneum').to be false }
  it { expect(metadata.student? 'baz').to be false }

  it { expect(Mumukit::Auth::Token.from_env({}).metadata.student? 'foo/bar').to be false }

  context 'when no permissions' do
    let(:metadata) { Mumukit::Auth::Metadata.new({}) }
    it { expect(metadata.add_permission!('atheneum', 'test/*').as_json).to eq({ 'atheneum' => { 'permissions' => 'test/*'} })}
  end

  context 'add_permission!' do
    let(:metadata) { Mumukit::Auth::Metadata.new({atheneum: { permissions: 'foo/bar' } }.deep_stringify_keys) }
    context 'when no permissions added' do
      before { metadata.add_permission!('classroom', 'test/*') }
      it { expect(metadata.teacher? 'test/*').to eq true}
    end
    context 'when no permissions added' do
      before { metadata.add_permission!('atheneum', 'test/*') }
      it { expect(metadata.student? 'test/*').to eq true}
    end
  end

  context 'remove_permission!' do
    let(:metadata) { Mumukit::Auth::Metadata.new({atheneum: { permissions: 'foo/bar:test/*:foo/baz' } }.deep_stringify_keys) }
    before { metadata.remove_permission!('atheneum', 'test/*') }
    it { expect(metadata.student? 'test/*').to eq false }
    it { expect(metadata.student? 'foo/bar').to eq true }
    it { expect(metadata.student? 'foo/baz').to eq true }
  end
end
