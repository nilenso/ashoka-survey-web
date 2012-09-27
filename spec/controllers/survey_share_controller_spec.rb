require 'spec_helper'

describe SurveyShareController do
  let(:survey) { FactoryGirl.create(:survey, :organization_id => 1) }

  before(:each) do
    sign_in_as('cso_admin')
    survey.publish

    session[:access_token] = "123"
    orgs_response = mock(OAuth2::Response)
    users_response = mock(OAuth2::Response)
    access_token = mock(OAuth2::AccessToken)
    controller.stub(:access_token).and_return(access_token)

    access_token.stub(:get).with('/api/organization_users').and_return(users_response)
    users_response.stub(:parsed).and_return([{"id" => 1, "name" => "Bob"}, {"id" => 2, "name" => "John"}])

    access_token.stub(:get).with('/api/organizations').and_return(orgs_response)
    orgs_response.stub(:parsed).and_return([{"id" => 1, "name" => "CSOOrganization"}, {"id" => 2, "name" => "Ashoka"}])
  end


  context "GET 'new'" do
    it "assigns the users in the current organization" do
      get :new, :survey_id => survey.id
      assigns(:users).should == [{"id" => 1, "name" => "Bob"}, {"id" => 2, "name" => "John"}]
    end

    it "assigns all the other organizations available" do
      get :new, :survey_id => survey.id
      assigns(:organizations).should == [{"id" => 2, "name" => "Ashoka"}]
    end

    it "assigns current survey" do
      get :new, :survey_id => survey.id
      assigns(:survey).should == survey
    end

    it "requires cso_admin for sharing a survey" do
      sign_in_as('user')
      get :new, :survey_id => survey.id
      response.should redirect_to surveys_path
      flash[:error].should_not be_empty
    end

    it "does not allow sharing of unpublished surveys" do
      unpublished_survey = FactoryGirl.create(:survey)
      get :new, :survey_id => unpublished_survey.id
      response.should redirect_to surveys_path
      flash[:error].should_not be_empty
    end
  end
end
