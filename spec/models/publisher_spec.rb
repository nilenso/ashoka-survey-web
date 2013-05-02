require 'spec_helper'

describe Publisher do
  before(:each) do
    @params = { :expiry_date => Date.tomorrow.to_s,
                :user_ids => [1,2],
                :participating_organization_ids => [2,3]}
  end

  context "validations" do
    it "checks whether the users_ids are valid" do
      survey = FactoryGirl.create(:survey, :public => false)
      client = stub
      publisher = Publisher.new(survey, client, @params)
      User.should_receive(:exists?).with(client, [1,2]).and_return(false)
      Organization.should_receive(:exists?).and_return(true)
      publisher.should_not be_valid
    end

    it "checks whether the org_ids are valid" do
      survey = FactoryGirl.create(:survey, :public => false)
      client = stub
      publisher = Publisher.new(survey, client, @params)
      User.should_receive(:exists?).and_return(true)
      Organization.should_receive(:exists?).with(client, [2, 3]).and_return(false)
      publisher.should_not be_valid
    end

    it "doesn't run the validation if survey is public" do
      survey = FactoryGirl.create(:survey, :public => true)
      client = stub
      publisher = Publisher.new(survey, client, @params)
      User.should_not_receive(:exists?).with(client, [1,2])
      publisher.should be_valid
    end

    it "doesn't run the validation if survey public @params is true" do
      survey = FactoryGirl.create(:survey)
      client = stub
      @params[:public] = '1'
      publisher = Publisher.new(survey, client, @params)
      User.should_not_receive(:exists?).with(client, [1,2])
      publisher.should be_valid
    end
  end

  it "publishes to all of ther users" do
    survey = FactoryGirl.create(:survey, :finalized => true)
    client = stub
    users = [1,2]
    orgs = [2, 3]
    @params[:public] = '1'
    publisher = Publisher.new(survey, client, @params)
    publisher.should_receive(:valid?).and_return(true)
    publisher.publish
    SurveyUser.all.map(&:user_id).should include(1,2)
    ParticipatingOrganization.all.map(&:organization_id).should include(2,3)
    survey.should be_public
  end

  it "sets the thank_you_message of a public survey" do
    survey = FactoryGirl.create(:survey, :finalized => true, :public => true)
    @params[:thank_you_message] = 'Thank You!'
    client = stub
    publisher = Publisher.new(survey, client, @params)
    publisher.should_receive(:valid?).and_return(true)
    publisher.publish
    survey.reload.thank_you_message.should == 'Thank You!'
  end

  it "unpublishes to all of ther users" do
    survey = FactoryGirl.create(:survey, :finalized => true)
    survey.survey_users.create(:user_id => 1)
    survey.survey_users.create(:user_id => 2)
    client = stub
    publisher = Publisher.new(survey, client, { :user_ids => [1, 2]})
    publisher.unpublish_users
    SurveyUser.all.map(&:user_id).should_not include(1,2)
  end

  it "doesn't share with organizations if the survey isn't owned by the current_org_id" do
    survey = FactoryGirl.create(:survey, :finalized => true, :organization_id => 42)
    client = stub
    publisher = Publisher.new(survey, client, @params.merge({ :organization_ids => [1, 2]}))
    publisher.should_receive(:valid?).and_return(true)
    expect { publisher.publish(:organization_id => 50) }.not_to change { ParticipatingOrganization.count }
  end
end
