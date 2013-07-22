require 'spec_helper'

describe OrganizationDashboardsController do
  context "GET index" do
    before(:each) do
      response = mock(OAuth2::Response)
      access_token = mock(OAuth2::AccessToken)
      controller.stub(:access_token).and_return(access_token)
      access_token.stub(:get).and_return(response)
      response.stub(:parsed).and_return([
        {"id" => 123, "name" => "foo", "logos" => {"thumb_url" => "http://foo.png"}},
        {"id" => 456, "name" => "bar", "logos" => {"thumb_url" => "http://foo.png"}}
      ])
      sign_in_as("super_admin")
    end

    it "fetches the list of organizations" do
      get :index
      assigns(:decorated_organizations).map(&:id).should == [123, 456]
    end
  end

  context "GET show" do
    let(:access_token) { mock(OAuth2::AccessToken) }

    before(:each) do
      controller.stub(:access_token).and_return(access_token)
      sign_in_as("super_admin")
    end

    it "fetches the requested organization" do
      response = mock(OAuth2::Response)
      access_token.stub(:get).and_return(response)
      response.stub(:parsed).and_return({"id" => 1, "name" => "foo", "logos" => {"thumb_url" => "http://foo.png"}})
      get :show, :id => 1
      organization = assigns(:decorated_organization)
      organization.id.should == 1
      organization.name.should == "foo"
    end

    it "returns an 404 if the id is invalid" do
      bad_response = mock(OAuth2::Response).as_null_object
      access_token.stub(:get).and_raise(OAuth2::Error.new(bad_response))
      get :show, :id => 42
      response.code.should == "404"
    end
  end
end
