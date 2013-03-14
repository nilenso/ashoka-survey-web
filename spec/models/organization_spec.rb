require 'spec_helper'

describe Organization do
  before(:each) do
    orgs_response = mock(OAuth2::Response)
    users_response = mock(OAuth2::Response)
    org_exists = mock(OAuth2::Response)
    @access_token = mock(OAuth2::AccessToken)

    @access_token.stub(:get).with('/api/organizations').and_return(orgs_response)
    orgs_response.stub(:parsed).and_return([{"id" => 1, "name" => "CSOOrganization"}, {"id" => 2, "name" => "Ashoka"}])

    @access_token.stub(:get).with('/api/organizations/1/users').and_return(users_response)
    users_response.stub(:parsed).and_return([{"id" => 1, "name" => "Bob", "role" => 'field_agent'}, {"id" => 2, "name" => "John", "role" => 'supervisor'}, {"id" => 3, "name" => "Rambo", "role" => 'cso_admin'}])

    @access_token.stub(:get).with('/api/organizations/validate_orgs', :params => { :org_ids => [1, 2].to_json}).and_return(org_exists)
    org_exists.stub(:parsed).and_return(true)
  end

  context "#all" do
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

    it "returns nil if access_token is nil" do
      Organization.all(nil).should be_nil
    end
  end

  context "#users" do
    it "returns all users for the particular organization" do
      users = Organization.users(@access_token, 1)
      users.map(&:id).should include(1, 2, 3)
      users.map(&:name).should include "Bob"
    end

    it "returns an empty array if the organization_id is nil" do
      users = Organization.users(@access_token, nil)
      users.should == []
    end
  end

  it "returns all field agents for the particular organization" do
    users = Organization.publishable_users(@access_token, 1)
    users.map(&:id).should_not include 3
    users.map(&:id).should include(1,2)
    users.map(&:name).should_not include "Rambo"
    users.map(&:name).should include("Bob","John")
  end

  it "returns true if the organizations exists" do
    org_ids = [1, 2]
    Organization.exists?(@access_token, org_ids).should be_true
  end

  it "creates an organization object from json" do
    organization = Organization.json_to_organization({"id" => 1, "name" => "Foo"})
    organization.class.should eq Organization
    organization.id.should eq 1
    organization.name.should eq "Foo"
  end
end
