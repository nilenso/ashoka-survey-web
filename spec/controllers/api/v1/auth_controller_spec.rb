require 'spec_helper'

module Api
  module V1
    describe AuthController do
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

        it "renders the OAuth token as JSON" do
          post :create, :email => 'admin@admin.com', :password => 'admin'
          response.should be_ok
          JSON.parse(response.body).should == { 'access_token' => "TOKEN!" }
        end
      end
    end
  end
end
