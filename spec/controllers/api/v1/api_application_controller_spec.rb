require 'spec_helper'

module Api
  module V1
    describe APIApplicationController do
      controller(APIApplicationController) do
        def index
          response = RSpec::Mocks::Mock.new(:error= => :error, :parsed => nil, :body => nil, :status => 401)
          raise OAuth2::Error.new(response)
        end
      end

      context "when there's an OAuth Error" do
        it "renders an :unauthorized" do
          get :index
          response.should_not be_ok
          response.status.should == 401
        end
      end

      context "cancan - access denied" do
        controller(APIApplicationController) do
          def create
            raise CanCan::AccessDenied.new("Not authorized!", :create, Survey)
          end
        end

        it "sends down a 401 Unauthorized" do
          sign_in_as('field_agent')
          post :create
          response.should_not be_ok
          response.status.should == 401
        end
      end

      context "when getting the current user's info" do
        controller(APIApplicationController) do
          def index
            @current_user_info = current_user_info
            render :nothing => true
          end
        end

        it "gets the info from the OAuth provider if a valid access token is passed" do
          OAuth2::AccessToken.any_instance.stub_chain(:get, :parsed).and_return({ 'organization' => {} })
          get :index, :access_token => "Foo"
          response.should be_ok
        end

        context "no access token in passed" do
          it "gets the info from the session if it exists" do
            sign_in_as("viewer")
            session[:user_id] = 12345
            get :index
            response.should be_ok
            assigns(:current_user_info)['user_id'].should == 12345
          end

          it "returns the same error returned by the OAuth provider if no session information exists" do
            response = mock("response").as_null_object
            response.stub(:status).and_return(401)
            OAuth2::AccessToken.any_instance.stub(:get).and_raise(OAuth2::Error.new(response))
            get :index
            response.should be_unauthorized
          end
        end

        context "when an invalid access token is passed" do
          before(:each) do
            response = mock("response").as_null_object
            response.stub(:status).and_return(401)
            OAuth2::AccessToken.any_instance.stub(:get).and_raise(OAuth2::Error.new(response))
          end

          it "returns the same error returned by the OAuth provider if session information exists" do
            sign_in_as("viewer")
            session[:user_id] = 12345
            get :index, :access_token => "fasdfasdas"
            response.should be_unauthorized
          end

          it "returns the same error returned by the OAuth provider if no session information exists" do
            get :index, :access_token => "fasdfasdas"
            response.should be_unauthorized
          end
        end
      end
    end
  end
end
