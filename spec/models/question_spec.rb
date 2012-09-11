require 'spec_helper'

describe Question do
  it { should respond_to :content }
  it { should belong_to :survey }
  it { should have_many(:answers).dependent(:destroy) }
  it { should have_many(:options).dependent(:destroy) }
  it { should validate_presence_of :content }
  it { should respond_to :mandatory }
  it { should have_attached_file(:image) }
  it { should respond_to :max_length }
  it { should accept_nested_attributes_for(:options) }
  it { should validate_numericality_of(:max_length) }

  context "validation" do
    it "ensures that the order number for a question is unique within a survey" do
      survey = FactoryGirl.create(:survey)
      question_1 = FactoryGirl.create(:question, :survey => survey, :order_number => 1)
      question_2 = FactoryGirl.build(:question, :survey => survey, :order_number => 1)
      question_2.should_not be_valid
    end

    it "doesn't allow a negative max-length" do
      survey = FactoryGirl.create(:survey)
      question = FactoryGirl.build(:question, :survey => survey, :max_length => -5)
      question.should_not be_valid
    end
  end

  context "mass assignment" do
    it { should allow_mass_assignment_of(:content) }
    it { should allow_mass_assignment_of(:mandatory) }
    it { should allow_mass_assignment_of(:image) }
    it { should allow_mass_assignment_of(:max_length) }
    it { should allow_mass_assignment_of(:type) }
    it { should allow_mass_assignment_of(:max_value) }
    it { should allow_mass_assignment_of(:min_value) }
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
end
