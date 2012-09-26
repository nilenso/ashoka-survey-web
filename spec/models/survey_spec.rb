require 'spec_helper'

describe Survey do
  it { should respond_to :name }
  it { should respond_to :expiry_date }
  it { should respond_to :description }
  it { should respond_to :published }
  it { should respond_to :organization_id }
  it { should respond_to :shared_org_ids }
  it { should have_many(:questions).dependent(:destroy) }
  it { should have_many(:responses).dependent(:destroy) }
  it { should accept_nested_attributes_for :questions }
  it {should belong_to :organization }

  context "when validating" do
    it { should validate_presence_of :name }

    it "should not accept an invalid expiry date" do
      survey = FactoryGirl.build(:survey, :expiry_date => nil)
      survey.should_not be_valid
    end

    it "validates the expiry date to not be in the past" do
      date = Date.new(1990,10,24)
      survey = FactoryGirl.build(:survey, :expiry_date => date)
      survey.should_not be_valid
    end

    it "deserializes the shared_org_ids" do
      survey = FactoryGirl.create(:survey, :shared_org_ids => [1, 2, 3])
      survey.reload.shared_org_ids.should eq [1, 2, 3]
    end
  end

  context "publish" do
    it "should not be published by default" do
      survey = FactoryGirl.create(:survey)
      survey.should_not be_published
    end

    it "changes published to true" do
      survey = FactoryGirl.create(:survey)
      survey.publish
      survey.should be_published
    end
  end

  context "users" do
    it "returns the list of users the survey is published to" do
      survey = FactoryGirl.create(:survey)
      survey_user = FactoryGirl.create(:survey_user, :survey_id => survey.id)
      survey.users.should == [survey_user.user_id]
    end
  end
end