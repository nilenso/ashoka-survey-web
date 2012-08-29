require 'spec_helper'

describe Option do
  it { should belong_to(:question) }
  it { should respond_to(:content) }
  it { should allow_mass_assignment_of(:content) }
  it { should allow_mass_assignment_of(:question_id) }
end
