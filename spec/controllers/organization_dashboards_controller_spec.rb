require 'spec_helper'

describe OrganizationDashboardsController do
  context "GET index" do
    before(:each) do
      response = mock(OAuth2::Response)
      access_token = mock(OAuth2::AccessToken)
      controller.stub(:access_token).and_return(access_token)
      access_token.stub(:get).and_return(response)
      response.stub(:parsed).and_return([{"id" => 123, "name" => "foo"}, {"id" => 456, "name" => "bar"}])
      sign_in_as("super_admin")
    end

    it "fetches the list of organizations" do
      get :index
      assigns(:organizations).map(&:id).should == [123, 456]
    end
  end
end
