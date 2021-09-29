require_relative '../spec_helper'

describe Mumukit::Auth::Role do

  it { expect(Mumukit::Auth::Role[:student]).to be Mumukit::Auth::Role[:student] }
  it { expect(Mumukit::Auth::Role[:student]).to be_a Mumukit::Auth::Role::Student }

  describe 'narrower_than?' do
    it { expect(Mumukit::Auth::Role[:student]).to be_narrower_than Mumukit::Auth::Role[:teacher] }
    it { expect(Mumukit::Auth::Role[:student]).to be_narrower_than Mumukit::Auth::Role[:admin] }
    it { expect(Mumukit::Auth::Role[:student]).to be_narrower_than Mumukit::Auth::Role[:owner] }

    it { expect(Mumukit::Auth::Role[:student]).to_not be_narrower_than Mumukit::Auth::Role[:ex_student] }
    it { expect(Mumukit::Auth::Role[:editor]).to_not be_narrower_than Mumukit::Auth::Role[:student] }

    it { expect(Mumukit::Auth::Role[:ex_student]).to be_narrower_than Mumukit::Auth::Role[:student] }
    it { expect(Mumukit::Auth::Role[:ex_student]).to be_narrower_than Mumukit::Auth::Role[:admin] }
  end
end