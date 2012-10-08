require 'spec_helper'

describe SingleLineQuestion do
  it { should respond_to :max_length }
  
  it "is a question with type = 'SingleLineQuestion'" do
    SingleLineQuestion.create(:content => "hello")
    question = Question.find_by_content("hello")
    question.should be_a SingleLineQuestion
    question.type.should == "SingleLineQuestion"
  end

  context "when validating max length" do
    it { should allow_mass_assignment_of(:max_length) }
    it { should validate_numericality_of(:max_length) }
    it "doesn't allow a negative max-length" do
      survey = FactoryGirl.create(:survey)
      question = SingleLineQuestion.new(:max_length => -5, :content => "foo")
      question.survey_id = survey.id
      question.should_not be_valid
    end
  end
end