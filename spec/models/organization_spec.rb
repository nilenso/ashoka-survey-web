require 'spec_helper'

describe Organization do
  before(:each) do 
    orgs_response = mock(OAuth2::Response)
    @access_token = mock(OAuth2::AccessToken)
    @access_token.stub(:get).with('/api/organizations').and_return(orgs_response)
    orgs_response.stub(:parsed).and_return([{"id" => 1, "name" => "CSOOrganization"}, {"id" => 2, "name" => "Ashoka"}])
  end

  it "returns the list of other organizations" do
    Organization.all_except(@access_token, 1).should include({"id" => 2, "name" => "Ashoka"} )
  end

  it "doesn't return self in other organization list" do
    Organization.all_except(@access_token, 1).should_not include({"id" => 1, "name" => "CSOOrganization"} )
  end
end
