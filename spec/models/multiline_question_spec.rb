require 'spec_helper'

describe MultilineQuestion do
  it { should respond_to :max_length }

  it "is a question with type = 'MultilineQuestion'" do
    MultilineQuestion.create(:content => "hello", :order_number => 11)
    question = Question.find_by_content("hello")
    question.should be_a MultilineQuestion
    question.type.should == "MultilineQuestion"
  end

  context "when validating max length" do
    it { should allow_mass_assignment_of(:max_length) }
    it { should validate_numericality_of(:max_length) }
    it "doesn't allow a negative max-length" do
      survey = FactoryGirl.create(:survey)
      question = MultilineQuestion.new(:max_length => -5, :content => "foo")
      question.survey_id = survey.id
      question.should_not be_valid
    end
  end
end
