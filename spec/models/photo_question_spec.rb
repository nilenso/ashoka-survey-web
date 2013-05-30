require 'spec_helper'

describe PhotoQuestion do
  context "when validating max length" do
    it { should allow_mass_assignment_of(:max_length) }
    it { should validate_numericality_of(:max_length) }
    it "doesn't allow a negative max-length" do
      survey = FactoryGirl.create(:survey)
      question = PhotoQuestion.new(:max_length => -5, :content => "foo")
      question.survey_id = survey.id
      question.should_not be_valid
    end
  end

  context "defaults" do
    it "is private by default" do
      question = PhotoQuestion.create(:content => "Foo")
      question.should be_private
    end
  end

  it_behaves_like "a question"
end
