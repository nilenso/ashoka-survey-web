require 'spec_helper'

describe Publisher do
  it "checks whether the users_ids are valid" do
    survey = FactoryGirl.create(:survey)
    client = stub
    publisher = Publisher.new(survey, [1,2], client)
    User.should_receive(:exists?).with(client, [1,2]).and_return(false)
    publisher.should_not be_valid
  end

  it "publishes to all of ther users" do
    survey = FactoryGirl.create(:survey, :finalized => true)
    client = stub
    users = [1,2]
    publisher = Publisher.new(survey, users, client)
    publisher.publish
    SurveyUser.all.map(&:user_id).should include(1,2)
  end
end
