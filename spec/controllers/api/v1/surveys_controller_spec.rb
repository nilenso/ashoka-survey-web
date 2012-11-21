require 'spec_helper'

module Api
  module V1
    describe SurveysController do
      let(:organization_id) { 12 }
      let(:survey) { FactoryGirl.create :survey, :organization_id => organization_id }

      before(:each) do
        sign_in_as('cso_admin')
        session[:user_info][:org_id] = organization_id
      end

      context "GET 'index'" do
        it "responds with JSON" do
          get :index
          response.should be_ok
          lambda { JSON.parse(response.body) }.should_not raise_error
        end

        it "responds with the id, name, expiry date and the description of the survey" do
          FactoryGirl.create(:survey)
          get :index
          returned_json = JSON.parse(response.body).first
          returned_json.keys.should =~ ['id', 'name', 'description', 'expiry_date']
        end

        it "responds with details for all the surveys stored" do
          surveys = FactoryGirl.create_list(:survey, 15)
          get :index
          returned_json = JSON.parse(response.body)
          returned_json.length.should == 15
          Survey.all.each_with_index do |survey, index|
            returned_json[index]['name'].should == survey.name
            returned_json[index]['description'].should == survey.description
            Date.parse(returned_json[index]['expiry_date']).should == survey.expiry_date
          end
        end
      end

      context "GET 'show" do

        it "returns the survey information as JSON" do
          get :show, :id => survey.id
          response.should be_ok
          JSON.parse(response.body).should == JSON.parse(survey.to_json)
        end

        it "returns a :bad_request if the survey isn't found" do
          get :show, :id => 1234
          response.should_not be_ok
        end
      end

      context "PUT 'update'" do

        it "updates the relevant survey" do
          put :update, :id => survey.id, :survey => { :name => "Smit" }
          response.should be_ok
          survey.reload.name.should == "Smit"
        end

        it "returns a :bad_request if the survey_id is invalid" do
          put :update, :id => 123, :survey => { :name => "Smit" }
          response.should_not be_ok
        end

        it "returns the errors if survey save fails" do
          put :update, :id => survey.id, :survey => { :expiry_date => -5.days.from_now }
          response.should_not be_ok
          response.body.should =~ /in the past/
        end
      end
    end
  end
end
