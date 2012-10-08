require 'spec_helper'

describe Question do
  it { should have_many(:options).dependent(:destroy) }
  it { should accept_nested_attributes_for(:options) }
    it { should allow_mass_assignment_of(:type) }

  context "validation" do
    it "ensures that the order number for a question is unique within a survey" do
      survey = FactoryGirl.create(:survey)
      question_1 = FactoryGirl.create(:question, :survey => survey, :order_number => 1)
      question_2 = FactoryGirl.build(:question, :survey => survey, :order_number => 1)
      question_2.should_not be_valid
    end
  end

  context "orders by order number" do
    it "fetches all question in ascending order of order_number for a particular survey" do
      survey = FactoryGirl.create(:survey)
      question = FactoryGirl.create(:question, :survey => survey)
      another_question = FactoryGirl.create(:question, :survey => survey)
      survey.questions == [question, another_question]
      question.order_number.should be < another_question.order_number
    end
  end

  include_examples 'a question'
end
