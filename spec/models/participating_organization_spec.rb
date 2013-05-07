require 'spec_helper'

describe ParticipatingOrganization do
  it { should validate_presence_of :survey_id }
  it { should validate_presence_of :organization_id }

  it "validates uniqueness of the (organization_id, survey_id) tuple" do
    survey = FactoryGirl.create :survey, :finalized => true
    ParticipatingOrganization.create(:survey_id => survey.id, :organization_id => 5)
    p_org = ParticipatingOrganization.new(:survey_id => survey.id, :organization_id => 5)
    p_org.should_not be_valid
    p_org = ParticipatingOrganization.new(:survey_id => survey.id, :organization_id => 6)
    p_org.should be_valid
  end

  it "validates that the survey it belongs to is finalized" do
    unfinalized_survey = FactoryGirl.create :survey, :finalized => false
    p_org = ParticipatingOrganization.create(:survey_id => unfinalized_survey.id, :organization_id => 5)
    p_org.should_not be_valid
  end
end
