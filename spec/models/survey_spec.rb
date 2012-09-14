require 'spec_helper'

describe Survey do
  it { should respond_to :name }
  it { should respond_to :expiry_date }
  it { should respond_to :description }
  it { should respond_to :published }
  it { should respond_to :owner_org_id }
  it { should have_many(:questions).dependent(:destroy) }
  it { should have_many(:responses).dependent(:destroy) }
  it { should accept_nested_attributes_for :questions }

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


  context "unpublish" do
    it "changes published to false" do
      survey = FactoryGirl.create(:survey, :published => true)
      survey.unpublish
      survey.should_not be_published
    end
  end
end