require 'spec_helper'

describe Organization do
  before(:each) do
    orgs_response = mock(OAuth2::Response)
    users_response = mock(OAuth2::Response)
    org_exists = mock(OAuth2::Response)
    single_organization_response = mock(OAuth2::Response)
    bad_response = mock(OAuth2::Response).as_null_object
    @access_token = mock(OAuth2::AccessToken)

    @access_token.stub(:get).with('/api/organizations').and_return(orgs_response)
    orgs_response.stub(:parsed).and_return([
      {"id" => 1, "name" => "CSOOrganization", "logos" => {"thumb_url" => nil}},
      {"id" => 2, "name" => "Ashoka", "logos" => {"thumb_url" => nil}}
    ])

    @access_token.stub(:get).with('/api/organizations/1/users').and_return(users_response)
    users_response.stub(:parsed).and_return([{"id" => 1, "name" => "Bob", "role" => 'field_agent'}, {"id" => 2, "name" => "John", "role" => 'supervisor'}, {"id" => 3, "name" => "Rambo", "role" => 'cso_admin'}])

    @access_token.stub(:get).with('/api/organizations/1').and_return(single_organization_response)
    single_organization_response.stub(:parsed).and_return({"id" => 1, "name" => "Apple", "logos" => {"thumb_url" => "http://foo.com/bar.png"}})

    @access_token.stub(:get).with('/api/organizations/42').and_raise(OAuth2::Error.new(bad_response))

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

  context "when fetching information for a single organization" do
    it "fetches the requested organization if it exists" do
      organization = Organization.find_by_id(@access_token, 1)
      organization.name.should == "Apple"
    end

    it "returns nil if the organization doesn't exist" do
      organization = Organization.find_by_id(@access_token, 42)
      organization.should be_nil
    end

    it "returns the logo for the organization" do
      organization = Organization.find_by_id(@access_token, 1)
      organization.logo_url.should == "http://foo.com/bar.png"
    end
  end

  context "when deleting an organization and its associated data" do
    it "deletes the organization's surveys" do
      organization = FactoryGirl.build(:organization)
      survey = FactoryGirl.create(:survey, :organization_id => organization.id)
      organization.destroy!
      Survey.find_by_id(survey.id).should_not be_present
    end

    it "deletes the surveys even if they have responses" do
      organization = FactoryGirl.build(:organization)
      survey = FactoryGirl.create(:survey, :organization_id => organization.id)
      response = FactoryGirl.create(:response, :survey => survey)
      organization.destroy!
      Survey.find_by_id(survey.id).should_not be_present
    end
  end

  it "finds deleted organizations" do
    FakeWeb.register_uri(:get, "#{ENV["OAUTH_SERVER_URL"]}/api/deleted_organizations", :body => [5, 6].to_json)
    organizations = Organization.deleted_organizations
    organizations.first.id.should == 5
  end
end
