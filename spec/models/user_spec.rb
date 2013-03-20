require 'spec_helper'

describe User do
  before(:each) do
    orgs_response = mock(OAuth2::Response)
    users_response = mock(OAuth2::Response)
    names_response = mock(OAuth2::Response)
    user_exists = mock(OAuth2::Response)

    @access_token = mock(OAuth2::AccessToken)

    @access_token.stub(:get).with('/api/organizations').and_return(orgs_response)
    orgs_response.stub(:parsed).and_return([{"id" => 1, "name" => "CSOOrganization", "role" => "field_agent"}, {"id" => 2, "name" => "Ashoka", "role" => "Field Agent"}])

    @access_token.stub(:get).with('/api/organizations/1/users').and_return(users_response)
    users_response.stub(:parsed).and_return([{"id" => 1, "name" => "Bob", "role" => "field_agent"}, {"id" => 2, "name" => "John", "role" => "field_agent"}])

    @access_token.stub(:get).with('/api/users/names_for_ids', :params => {:user_ids => [1,2].to_json}).and_return(names_response)
    names_response.stub(:parsed).and_return([{"id" => 1, "name" => "Bob"}, {"id" => 2, "name" => "John"}])

    @access_token.stub(:get).with('/api/users/validate_users', :params => {:user_ids => [1,2].to_json}).and_return(user_exists)
    user_exists.stub(:parsed).and_return(true)
  end

  it "returns the list of users of an organizations" do
    users = User.find_by_organization(@access_token, 1)
    users.map(&:id).should include 1
    users.map(&:name).should include "Bob"
    users.map(&:role).should include 'field_agent'
  end

  it "creates a user object from json" do
    user = User.json_to_user({"id" => 1, "name" => "John", "role" => "field_agent"})
    user.class.should eq User
    user.id.should eq 1
    user.name.should eq "John"
  end

  context "when getting user ids and names for ids passed in" do
    it "returns the user ids if logged in" do
      user_ids = [1, 2]
      User.names_for_ids(@access_token, user_ids).should == { 1 => "Bob", 2 => "John"}
    end

    it "returns an empty hash if not logged in" do
      user_ids = [1, 2]
      User.names_for_ids(nil, user_ids).should == {}
    end
  end

  context "checks whether all the user exists or not" do
    it "returns true if the user exists" do
      user_ids = [1, 2]
      User.exists?(@access_token, user_ids).should be_true
    end

    it "returns an empty hash if not logged in" do
      user_ids = [1, 2]
      User.names_for_ids(nil, user_ids).should == {}
    end

    it "checks if whether the user is publishable or not" do
      user = User.json_to_user({"id" => 1, "name" => "John", "role" => "field_agent"})
      another_user = User.json_to_user({"id" => 1, "name" => "John", "role" => "cso_admin"})
      user.should be_publishable
      another_user.should_not be_publishable
    end
  end
end
