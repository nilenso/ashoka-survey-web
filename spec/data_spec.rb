require 'spec_helper'

describe Reports::Excel::Data do
  let(:access_token) { access_token = mock(OAuth2::AccessToken) }

  it "finds the user name for an ID" do
    names_response = mock(OAuth2::Response)
    access_token.stub(:get).with('/api/users/names_for_ids', :params => {:user_ids => [1].to_json}).and_return(names_response)
    names_response.stub(:parsed).and_return([{"id" => 1, "name" => "Bob"}])

    response = FactoryGirl.create(:response, :user_id => 1)
    data = Reports::Excel::Data.new(Response.where(:user_id => 1), access_token)
    data.user_name_for(1).should == "Bob"
  end

  context "when fetching responses" do
    it "fetches only the complete responses" do
      complete_response = FactoryGirl.create(:response, :status => "complete")
      incomplete_response = FactoryGirl.create(:response, :status => "incomplete")
      data = Reports::Excel::Data.new(Response.scoped, access_token)
      data.responses.should == [complete_response]
    end

    it "orders the responses by `updated_at`" do
      old_response = Timecop.freeze(5.days.ago) { FactoryGirl.create(:response, :status => "complete") }
      new_response = Timecop.freeze(5.days.from_now) { FactoryGirl.create(:response, :status => "complete") }
      data = Reports::Excel::Data.new(Response.scoped, access_token)
      data.responses.should == [old_response, new_response]
    end
  end
end
