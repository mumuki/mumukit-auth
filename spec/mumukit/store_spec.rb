require_relative '../spec_helper'

describe Mumukit::Auth::Store do
  let(:db) { Mumukit::Auth::Store.new('test') }

  describe '#set!' do
    before { db.set! 'foo@bar.org', {teacher: 'bar/*'} }
    it { expect(db.get('foo@bar.org').has_role? 'teacher').to be_true }
    it { expect(db.get('foo@bar.org').has_role? 'student').to be_false }
  end
end
