require_relative '../spec_helper'

describe Mumukit::Auth::Role do

  it { expect(:student.to_mumukit_role).to be :student.to_mumukit_role }
  it { expect('student'.to_mumukit_role).to be :student.to_mumukit_role }
  it { expect(:student.to_mumukit_role.to_mumukit_role).to be :student.to_mumukit_role }
  it { expect(:student.to_mumukit_role).to be_a Mumukit::Auth::Role::Student }

  describe 'narrower_than?' do
    it { expect(:student.to_mumukit_role).to be_narrower_than :teacher.to_mumukit_role }
    it { expect(:student.to_mumukit_role).to be_narrower_than :admin.to_mumukit_role }
    it { expect(:student.to_mumukit_role).to be_narrower_than :owner.to_mumukit_role }

    it { expect(:student.to_mumukit_role).to_not be_narrower_than :ex_student.to_mumukit_role }
    it { expect(:editor.to_mumukit_role).to_not be_narrower_than :student.to_mumukit_role }

    it { expect(:ex_student.to_mumukit_role).to be_narrower_than :student.to_mumukit_role }
    it { expect(:ex_student.to_mumukit_role).to be_narrower_than :admin.to_mumukit_role }
  end
end
