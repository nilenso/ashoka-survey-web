require 'spec_helper'

shared_examples "a question with max length" do
  let(:question_with_max_length)  {described_class.new(:content => "foo", :max_length => -5) }

  context "when validating max length" do
    it { should respond_to :max_length }
    it { should allow_mass_assignment_of(:max_length) }
    it { should validate_numericality_of(:max_length) }
    it "doesn't allow a negative max-length" do
  	  survey = FactoryGirl.create(:survey)
  	  question_with_max_length.survey_id = survey.id
      question_with_max_length.should_not be_valid
    end
  end
end
