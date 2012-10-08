require 'spec_helper'

describe Organization do
  before(:each) do 
    orgs_response = mock(OAuth2::Response)
    users_response = mock(OAuth2::Response)
    @access_token = mock(OAuth2::AccessToken)

    @access_token.stub(:get).with('/api/organizations').and_return(orgs_response)
    orgs_response.stub(:parsed).and_return([{"id" => 1, "name" => "CSOOrganization"}, {"id" => 2, "name" => "Ashoka"}])

    @access_token.stub(:get).with('/api/organizations/1/users').and_return(users_response)
    users_response.stub(:parsed).and_return([{"id" => 1, "name" => "Bob"}, {"id" => 2, "name" => "John"}])
  end

  it "returns the list of all organizations" do
    organizations = Organization.all(@access_token)
    organizations.map(&:id).should include 2
    organizations.map(&:name).should include "Ashoka"
  end

  it "returns the list of all organizations except a specified organization" do
    organizations = Organization.all(@access_token, :except => 1)
    organizations.map(&:id).should_not include 1
    organizations.map(&:name).should_not include "CSOOrganization"
  end

  it "returns all users for the particular organization" do
    users = Organization.users(@access_token, 1)
    users.map(&:id).should include 1
    users.map(&:name).should include "Bob"
  end

  it "creates an organization object from json" do
    organization = Organization.json_to_organization({"id" => 1, "name" => "Foo"})
    organization.class.should eq Organization
    organization.id.should eq 1
    organization.name.should eq "Foo"
  end
end
