require 'spec_helper'

module Api
  module V1
    describe SessionsController do
      context "POST 'create'" do

        before(:each) do
          client = double('client')
          password = double('password')
          access_token = double('access_token')
          response = double('response')
          parsed_response = { "email" => "admin@admin.com",
                              "id" => 1,
                              "name" => "admin",
                              "organization_id" => 1,
                              "role" => "admin"
                              }
          OAuth2::Client.stub(:new).and_return(client)
          client.stub(:password).and_return(password)
          password.stub(:get_token).and_return(access_token)
          access_token.stub(:get).and_return(response)
          access_token.stub(:token).and_return("TOKEN!")
          response.stub(:parsed).and_return(parsed_response)
        end

        context "when creating a session" do
          it "assigns the user ID to the session hash" do
            post :create, :email => 'admin@admin.com', :password => 'admin'
            response.should be_ok
            session[:user_id].should == 1
          end

          it "assigns the user info in the session hash" do
            post :create, :email => 'admin@admin.com', :password => 'admin'
            response.should be_ok
            session[:user_info].should == { name: 'admin', email: 'admin@admin.com', role: 'admin', org_id: 1 }
          end
        end

        it "renders the user info as JSON" do
          post :create, :email => 'admin@admin.com', :password => 'admin'
          response.should be_ok
          JSON.parse(response.body).should == {
            "user_id" => 1,
            "user_info" => {
              "email" => "admin@admin.com",
              "name" => "admin",
              "org_id" => 1,
              "role" => "admin"
            }
          }
        end
      end
    end
  end
end
