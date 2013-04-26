require 'spec_helper'

describe Reports::Excel::Data do
  let(:survey) { FactoryGirl.create(:survey) }
  let(:access_token) { access_token = mock(OAuth2::AccessToken) }

  it "finds the user name for an ID" do
    names_response = mock(OAuth2::Response)
    access_token.stub(:get).with('/api/users/names_for_ids', :params => {:user_ids => [1].to_json}).and_return(names_response)
    names_response.stub(:parsed).and_return([{"id" => 1, "name" => "Bob"}])

    response = FactoryGirl.create(:response, :user_id => 1)
    data = Reports::Excel::Data.new(survey, [response], access_token)
    data.user_name_for(1).should == "Bob"
  end

  it "finds the organization name for an ID" do
    orgs_response = mock(OAuth2::Response)
    access_token.stub(:get).with('/api/organizations').and_return(orgs_response)
    orgs_response.stub(:parsed).and_return([{"id" => 1, "name" => "CSOOrganization"}, {"id" => 2, "name" => "Ashoka"}])

    data = Reports::Excel::Data.new(survey, [], access_token)
    data.organization_name_for(1).should == "CSOOrganization"
  end
end
