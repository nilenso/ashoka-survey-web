require 'spec_helper'

describe ParticipatingOrganization do
  it { should respond_to :survey_id }
  it { should respond_to :organization_id }
  it { should belong_to :survey }

  it "validates uniqueness of the (organization_id, survey_id) tuple" do
    ParticipatingOrganization.create(:survey_id => 5, :organization_id => 5)
    p_org = ParticipatingOrganization.new(:survey_id => 5, :organization_id => 5)
    p_org.should_not be_valid
    p_org = ParticipatingOrganization.new(:survey_id => 5, :organization_id => 6)
    p_org.should be_valid
  end
end
