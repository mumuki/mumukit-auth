require_relative '../spec_helper'

describe Mumukit::Auth::Store do
  describe '#set!' do
    before { Mumukit::Auth::Store.set! 'foo@bar.org', {teacher: 'bar/*'} }
    it { expect(Mumukit::Auth::Store.get('foo@bar.org').has_role? 'teacher').to be_true }
    it { expect(Mumukit::Auth::Store.get('foo@bar.org').has_role? 'student').to be_false }
  end
end
