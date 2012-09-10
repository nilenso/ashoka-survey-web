require 'spec_helper'

describe Option do
  it { should belong_to(:question) }
  it { should respond_to(:content) }
  it { should allow_mass_assignment_of(:content) }
  it { should allow_mass_assignment_of(:question_id) }
  it { should validate_presence_of(:content) }
  it { should validate_presence_of(:question_id) }

  context "validation" do
    it "Ensures that the order number for an option is unique within a question" do
      question = FactoryGirl.create(:question, :type => "RadioQuestion")
      option_1 = FactoryGirl.create(:option, :question => question, :order_number => 1)
      option_2 = FactoryGirl.build(:option, :question => question, :order_number => 1)
      option_2.should_not be_valid
    end
  end
end
