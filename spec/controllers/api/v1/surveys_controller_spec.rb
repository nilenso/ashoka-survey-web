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
    before(:each) do
      Organization.stub(:find_by_id).and_return(Organization.new(1, :logo_url => "http://foo.bar/logo.png"))
    end

    it "returns the survey information as JSON" do
      get :show, :id => survey.id
      json = JSON.parse(response.body)
      response.should be_ok
      %w(id name description finalized organization_id public published_on archived).each do |attr|
        json[attr].should == survey[attr]
      end
    end

    it "returns a :bad_request if the survey isn't found" do
      get :show, :id => 1234
      response.should_not be_ok
    end

    it "returns all the elements of the survey as well" do
      get :show, :id => survey.id
      response.should be_ok
      JSON.parse(response.body).should have_key 'elements'
    end

    it "includes the survey logo in the description" do
      get :show, :id => survey.id
      response_hash = JSON.parse(response.body)
      response_hash["organization_logo_url"].should == "http://foo.bar/logo.png"
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

    it "returns the full errors if survey save fails" do
      put :update, :id => survey.id, :survey => { :expiry_date => -5.days.from_now }
      response.should_not be_ok
      JSON.parse(response.body)["full_errors"].first.should =~ /Expires on must be after/
    end

    it "returns the errors if survey save fails" do
      put :update, :id => survey.id, :survey => { :expiry_date => -5.days.from_now }
      response.should_not be_ok
      JSON.parse(response.body)["errors"]["expiry_date"].first.should =~ /must be after/
    end

    it "sends an event to mixpanel" do
      expect do
        put :update, :id => survey.id, :survey => { :name => "Smit" }
      end.to change { Delayed::Job.count }.by(1)
    end
  end

  context "POST 'duplicate'" do
    before(:each) do
      sign_in_as('cso_admin')
      session[:user_info][:org_id] = 123
      request.env["HTTP_REFERER"] = 'http://google.com'
    end

    it "creates a delayed job" do
      survey = FactoryGirl.create(:survey, :organization_id => 123)
      expect {
        post :duplicate, :id => survey.id
      }.to change { Delayed::Job.where(:queue => "survey_duplication").count }.by 1
    end

    it "renders the ID of the delayed job in JSON" do
      survey = FactoryGirl.create(:survey, :organization_id => 123)
      request.env["HTTP_REFERER"] = 'http://google.com'
      post :duplicate, :id => survey.id
      json = JSON.parse(response.body).symbolize_keys
      json[:job_id].should == Delayed::Job.where(:queue => "survey_duplication").last.id
    end

    context "when the user duplicating the survey doesn't belong to the same organization as the user who created it" do
      it "creates a survey with the current org id" do
        session[:user_info][:org_id] = 123
        survey = FactoryGirl.create(:survey, :finalized, :name => "Foo", :organization_id => 42)
        ParticipatingOrganization.create(:survey_id => survey.id, :organization_id => 123)
        post :duplicate, :id => survey.id
        Delayed::Worker.new.work_off
        duplicated_survey = Survey.order("created_at DESC").first
        duplicated_survey.should_not == survey
        duplicated_survey.organization_id.should == 123
      end
    end

    it "sends an event to mixpanel" do
      expect do
        post :duplicate, :id => survey.id
      end.to change { Delayed::Job.where(:queue => "mixpanel").count }.by(1)
    end
  end
end
