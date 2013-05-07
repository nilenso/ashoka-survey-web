require 'spec_helper'

describe SurveyUser do
  let(:draft_survey) { FactoryGirl.create(:survey) }
  let(:finalized_survey) { FactoryGirl.create(:survey, :finalized => true) }
  subject { SurveyUser.create(:survey_id => draft_survey.id, :user_id => 1) }

  context "when validating that the survey is finalized" do

    it "fails when the survey is not finalized" do
      survey_user = SurveyUser.create(:survey_id => draft_survey.id, :user_id => 5)
      survey_user.should_not be_valid
    end

    it "adds a validation error if it fails" do
      survey_user = SurveyUser.create(:survey_id => draft_survey.id, :user_id => 5)
      survey_user.should_not be_valid
    end

    it "passes when the survey is finalized" do
      survey_user = SurveyUser.create(:survey_id => finalized_survey.id, :user_id => 5)
      survey_user.should be_valid
    end
  end

  it "validates uniqueness of the (survey_id, user_id) tuple" do
    SurveyUser.create(:survey_id => finalized_survey.id, :user_id => 5)
    survey_user = SurveyUser.new(:survey_id => finalized_survey.id, :user_id => 5)
    survey_user.should_not be_valid
    survey_user = SurveyUser.new(:survey_id => finalized_survey.id, :user_id => 6)
    survey_user.should be_valid
  end
end
