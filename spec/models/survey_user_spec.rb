require 'spec_helper'

describe SurveyUser do
  subject { SurveyUser.create(:survey_id => 1, :user_id => 1) }

  it { should respond_to :survey_id }
  it { should respond_to :user_id }
  it { should belong_to :survey }

  it "validates uniqueness of the (survey_id, user_id) tuple" do
    SurveyUser.create(:survey_id => 5, :user_id => 5)
    survey_user = SurveyUser.new(:survey_id => 5, :user_id => 5)
    survey_user.should_not be_valid
    survey_user = SurveyUser.new(:survey_id => 5, :user_id => 6)
    survey_user.should be_valid
  end
end
