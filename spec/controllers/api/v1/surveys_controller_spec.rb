require 'spec_helper'

describe Api::V1::SurveysController do
  let(:survey) { FactoryGirl.create :survey, :organization_id => LOGGED_IN_ORG_ID, :finalized => true }

  before(:each) do
    sign_in_as('cso_admin')
    response = double('response')
    parsed_response = { "email" => "admin@admin.com",
                        "id" => 1,
                        "name" => "cso_admin",
                        "organization_id" => LOGGED_IN_ORG_ID,
                        "role" => "cso_admin"
                        }

    access_token = double('access_token')
    OAuth2::AccessToken.stub(:new).and_return(access_token)
    access_token.stub(:get).and_return(response)
    response.stub(:parsed).and_return(parsed_response)
  end

  context "GET 'index'" do
    it "responds with JSON" do
      get :index
      response.should be_ok
      lambda { JSON.parse(response.body) }.should_not raise_error
    end

    it "responds with the details of the survey as JSON" do
      FactoryGirl.create(:survey, :organization_id => LOGGED_IN_ORG_ID, :finalized => true)
      get :index
      returned_json = JSON.parse(response.body).first
       returned_json.keys.should =~ Survey.attribute_names
    end

    it "returns only the finalized surveys" do
      survey = FactoryGirl.create(:survey, :organization_id => LOGGED_IN_ORG_ID)
      finalized_survey = FactoryGirl.create(:survey, :organization_id => LOGGED_IN_ORG_ID, :finalized => true, :name => 'Finalized Survey')
      get :index
      returned_json = JSON.parse(response.body)
      returned_json.length.should == 1
      returned_json.first['name'].should == 'Finalized Survey'
    end

    it "doesn't return any expired surveys by default" do
      expired_surveys = FactoryGirl.create_list :survey, 5, :organization_id => LOGGED_IN_ORG_ID, :finalized => true
      expired_surveys.each { |survey| survey.update_attribute :expiry_date, 5.days.ago }
      surveys = FactoryGirl.create_list :survey, 5, :organization_id => LOGGED_IN_ORG_ID, :expiry_date => 5.days.from_now, :finalized => true
      get :index
      returned_json = JSON.parse response.body
      returned_json.length.should == 5
      returned_json.each do |survey|
        (Time.now < Time.parse(survey['expiry_date'])).should == true
      end
    end

    context "when fetching extra expired surveys" do
      it "returns all the surveys specified in params[:extra_surveys]" do
        FactoryGirl.create_list :survey, 5, :organization_id => LOGGED_IN_ORG_ID, :finalized => true
        first_expired_survey = FactoryGirl.create(:survey, :organization_id => LOGGED_IN_ORG_ID, :finalized => true, :name => 'First EXPIRED!')
        second_expired_survey = FactoryGirl.create(:survey, :organization_id => LOGGED_IN_ORG_ID, :finalized => true, :name => 'Second EXPIRED!')
        first_expired_survey.update_attribute :expiry_date, 5.days.ago
        second_expired_survey.update_attribute :expiry_date, 5.days.ago

        get :index, :extra_surveys => "#{first_expired_survey.id},#{second_expired_survey.id}"
        returned_json = JSON.parse response.body
        returned_json.length.should == 7
        returned_json.map { |survey| survey['name'] }.should include "First EXPIRED!"
        returned_json.map { |survey| survey['name'] }.should include "Second EXPIRED!"
      end

      it "resolves duplicates" do
        survey = FactoryGirl.create :survey, :organization_id => LOGGED_IN_ORG_ID, :finalized => true
        get :index, :extra_surveys => "#{survey.id}"
        returned_json = JSON.parse response.body
        returned_json.length.should == 1
      end

      it "ignores the surveys that the user doesn't have access to" do
        sign_in_as('viewer')
        survey = FactoryGirl.create :survey, :organization_id => LOGGED_IN_ORG_ID, :finalized => true
        off_limits_survey = FactoryGirl.create :survey, :organization_id => 1234, :finalized => true, :name => "OFF!"
        get :index
        returned_json = JSON.parse response.body
        returned_json.length.should == 1
        returned_json.map { |survey| survey['name'] }.should_not include "OFF!"
      end
    end

    it "responds with details for all the surveys stored" do
      FactoryGirl.create_list(:survey, 15, :organization_id => LOGGED_IN_ORG_ID, :finalized => true)
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

  context "GET 'question_count'" do
    it "returns the count of questions for surveys" do
      FactoryGirl.create_list(:survey_with_questions, 5, :organization_id => LOGGED_IN_ORG_ID)
      get :questions_count
      JSON.parse(response.body)['count'].should == 25
    end
  end
  
  context "GET 'identifier_questions'" do
    it "responds with JSON" do
      get :identifier_questions, :id => survey.id
      response.should be_ok
      lambda { JSON.parse(response.body) }.should_not raise_error
    end

    it "responds with the details of the survey as JSON" do
      survey = FactoryGirl.create(:survey, :organization_id => LOGGED_IN_ORG_ID)
      question = FactoryGirl.create(:question, :identifier => true)
      survey.questions << question

      get :identifier_questions, :id => survey.id
      response.should be_ok
      excluded_keys = ['created_at', 'updated_at', 'image']
      returned_json = JSON.parse(response.body)
      returned_json[0].except(*excluded_keys).should == question.as_json.except(*excluded_keys)
    end

    it "returns a :bad_request if an invalid survey ID is passed" do
      get :identifier_questions, :id => 40
      response.should_not be_ok
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
    end
  end
end
