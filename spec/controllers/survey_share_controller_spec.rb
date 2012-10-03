require 'spec_helper'

describe SurveyShareController do
  let(:survey) { FactoryGirl.create(:survey, :organization_id => 1) }

  before(:each) do
    sign_in_as('cso_admin')
    session[:user_info][:org_id] = 1
    survey.publish

    session[:access_token] = "123"
    orgs_response = mock(OAuth2::Response)
    users_response = mock(OAuth2::Response)
    access_token = mock(OAuth2::AccessToken)
    controller.stub(:access_token).and_return(access_token)

    access_token.stub(:get).with('/api/organizations/1/users').and_return(users_response)
    users_response.stub(:parsed).and_return([{"id" => 1, "name" => "Bob"}, {"id" => 2, "name" => "John"}])

    access_token.stub(:get).with('/api/organizations').and_return(orgs_response)
    orgs_response.stub(:parsed).and_return([{"id" => 1, "name" => "CSOOrganization"}, {"id" => 2, "name" => "Ashoka"}])
  end


  context "GET 'edit'" do
    it "assigns the users in the current organization" do
      get :edit, :survey_id => survey.id
      assigns(:users).should == [{"id" => 1, "name" => "Bob"}, {"id" => 2, "name" => "John"}]
    end

    it "assigns all the other organizations available" do
      get :edit, :survey_id => survey.id
      assigns(:other_organizations).should == [{"id" => 2, "name" => "Ashoka"}]
    end

    it "assigns current survey" do
      get :edit, :survey_id => survey.id
      assigns(:survey).should == survey
    end

    it "does not allow sharing of unpublished surveys" do
      unpublished_survey = FactoryGirl.create(:survey, :organization_id => 1)
      get :edit, :survey_id => unpublished_survey.id
      response.should redirect_to surveys_path
      flash[:error].should_not be_empty
    end
  end

  context "PUT 'update'" do
    it "adds the users to the survey" do
      put :update, :survey_id => survey.id, :survey => { :user_ids => [1, 2], :participating_organization_ids => [] }
      Survey.find(survey.id).user_ids.should == [1, 2]
    end

    it "updates the list of shared organizations" do
      participating_organizations = [12, 45]
      put :update, :survey_id => survey.id, :survey => { :user_ids => [1, 2], :participating_organization_ids => participating_organizations }
      survey.participating_organizations.map(&:organization_id).should == [12, 45]
    end

    it "removes the previous shared_users and participating_organizations for the survey" do
      participating_organizations = [12, 45]
      put :update, :survey_id => survey.id, :survey => { :user_ids => [1, 2], :participating_organization_ids => participating_organizations }
      put :update, :survey_id => survey.id, :survey => { :user_ids => [1], :participating_organization_ids => [12] }
      survey.participating_organizations.map(&:organization_id).should_not include 45
      survey.survey_users.map(&:user_id).should_not include 2
    end

    it "redirects to the surveys page with success flash" do
      participating_organizations = [12, 45]
      put :update, :survey_id => survey.id, :survey => { :user_ids => [1,2], :participating_organization_ids => participating_organizations }
      flash[:notice].should_not be_nil
      response.should redirect_to surveys_path
    end
  end
end
