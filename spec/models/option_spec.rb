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
      question = RadioQuestion.create( :type => "RadioQuestion", :content => "hollo!")
      option_1 = FactoryGirl.create(:option, :question => question, :order_number => 1)
      option_2 = FactoryGirl.build(:option, :question => question, :order_number => 1)
      option_2.should_not be_valid
    end
  end

  context "orders by order number" do
    it "fetches all option in ascending order of order_number for a particular question" do
      question = RadioQuestion.create( :content => "hollo!")
      option = FactoryGirl.create(:option, :question => question, :order_number => 2)
      another_option = FactoryGirl.create(:option, :question => question, :order_number => 1)
      question.options.last.should == option
      question.options.first.should == another_option
    end
  end
end
