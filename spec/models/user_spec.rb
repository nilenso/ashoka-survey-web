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
    users_response.stub(:parsed).and_return([{"id" => 1, "name" => "Bob", "role" => "field_agent", "email" => "foo@bar.com"},
                                            {"id" => 2, "name" => "John", "role" => "field_agent", "email" => "bar@foo.com"}])

    @access_token.stub(:get).with('/api/users/users_for_ids', :params => {:user_ids => [1].to_json}).and_return(names_response)
    names_response.stub(:parsed).and_return([{"id" => 1, "name" => "Bob", "email" => "foo@foo.com", "role" => "admin"}])

    @access_token.stub(:get).with('/api/users/validate_users', :params => {:user_ids => [1,2].to_json}).and_return(user_exists)
    user_exists.stub(:parsed).and_return(true)
  end

  it "returns the list of users of an organizations" do
    users = User.find_by_organization(@access_token, 1)
    user = users.first
    user.id.should == 1
    user.name.should == "Bob"
    user.role.should == 'field_agent'
    user.email.should == "foo@bar.com"
  end

  context "when getting user info for ids passed in" do
    it "returns the user ids if logged in" do
      user_ids = [1]
      user = User.users_for_ids(@access_token, user_ids)[0]
      user.name.should == "Bob"
      user.id.should == 1
    end

    it "returns an empty hash if not logged in" do
      user_ids = [1]
      User.users_for_ids(nil, user_ids).should == {}
    end
  end

  context "checks whether all the user exists or not" do
    it "returns true if the user exists" do
      user_ids = [1, 2]
      User.exists?(@access_token, user_ids).should be_true
    end

    it "returns an empty hash if not logged in" do
      user_ids = [1, 2]
      User.users_for_ids(nil, user_ids).should == {}
    end

    it "checks if whether the user is publishable or not" do
      user = User.json_to_user({"id" => 1, "name" => "John", "role" => "field_agent"})
      another_user = User.json_to_user({"id" => 1, "name" => "John", "role" => "cso_admin"})
      user.should be_publishable
      another_user.should_not be_publishable
    end
  end
end
