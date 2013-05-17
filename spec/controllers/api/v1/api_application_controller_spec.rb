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
    end
  end
end
