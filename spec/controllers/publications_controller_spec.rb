require 'spec_helper'

describe PublicationsController do
  render_views

  let(:survey) { FactoryGirl.create(:survey, :organization_id => 1, :finalized => true) }

  before(:each) do
    sign_in_as('cso_admin')
    session[:user_info][:org_id] = 1

    session[:access_token] = "123"
    users_response = mock(OAuth2::Response)
    access_token = mock(OAuth2::AccessToken)
    controller.stub(:access_token).and_return(access_token)

    access_token.stub(:get).with('/api/organizations/1/users').and_return(users_response)
    users_response.stub(:parsed).and_return([{"id" => 1, "name" => "Bob", "role" => "field_agent"}, {"id" => 2, "name" => "John", "role" => "field_agent"}, {"id" => session[:user_id], "name" => "CSOAdmin", "role" => "cso_admin"}])

    orgs_response = mock(OAuth2::Response)
    access_token.stub(:get).with('/api/organizations').and_return(orgs_response)
    orgs_response.stub(:parsed).and_return([{"id" => 1, "name" => "CSOOrganization"}, {"id" => 2, "name" => "Ashoka"}, {"id" => 3, "name" => "FooOrganization"} ])
  end

  context "GET 'edit'" do
    context "when the survey is not finalized" do
      it "redirects back to root with a flash error" do
        draft_survey = FactoryGirl.create(:survey)
        get :edit, :survey_id => draft_survey.id
        response.should redirect_to surveys_path
        flash[:error].should_not be_empty
      end
    end

    it "assigns survey's users and other users in the current organization" do
      survey.survey_users << FactoryGirl.create(:survey_user, :user_id => 1, :survey_id => survey.id)
      get :edit, :survey_id => survey.id
      assigns(:published_users).map{ |user| {:id => user.id, :name => user.name} }
      .should include({:id=>1, :name=>"Bob"})
      assigns(:unpublished_users).map{ |user| {:id => user.id, :name => user.name} }
      .should include({:id=>2, :name=>"John"})
    end

    it "assigns current survey" do
      get :edit, :survey_id => survey.id
      assigns(:survey).should == survey
    end

    it "doesn't assign the currently logged in user" do
      get :edit, :survey_id => survey.id
      assigns(:published_users).map(&:id).should_not include session[:user_id]
      assigns(:unpublished_users).map(&:id).should_not include session[:user_id]
    end

    it "assigns shared and unshared organizations" do
      survey.participating_organizations << FactoryGirl.create(:participating_organization, :organization_id => 2, :survey_id => survey.id)
      get :edit, :survey_id => survey.id
      assigns(:shared_organizations).map{ |org| {:id => org.id, :name => org.name} }
      .should include({:id=>2, :name=>"Ashoka"})
      assigns(:unshared_organizations).map{ |org| {:id => org.id, :name => org.name} }
      .should include({:id=>3, :name=>"FooOrganization"})
    end

    it "assigns current survey" do
      get :edit, :survey_id => survey.id
      assigns(:survey).should == survey
    end
  end

  context "PUT 'update'" do
    it "publishes the survey to chosen users" do
      put :update, :survey_id => survey.id, :survey => {:user_ids => [1, 2]}
      survey.reload.user_ids.should == [1, 2]
      flash[:notice].should_not be_nil
    end

    it "redirects to the share with organizations page" do
      put :update, :survey_id => survey.id, :survey => {:user_ids => [1, 2]}
      response.should redirect_to surveys_path
    end

    it "redirects back to the edit page with an error when no user ids are selected" do
      request.env["HTTP_REFERER"] = 'http://google.com'
      put :update, :survey_id => survey.id, :survey => {:user_ids => []}
      response.should redirect_to 'http://google.com'
      flash[:error].should_not be_nil
    end

    it "updates the list of shared organizations" do
      participating_organizations = [12, 45]
      put :update, :survey_id => survey.id, :survey => { :participating_organization_ids => participating_organizations }
      survey.participating_organizations.map(&:organization_id).should == [12, 45]
    end

    it "redirects to the survey's responses page" do
      put :update, :survey_id => survey.id, :survey => {:participating_organization_ids => [1, 2]}
      response.should redirect_to surveys_path
    end

    it "redirects back to the previous page with an error when no organizations are selected" do
      request.env["HTTP_REFERER"] = 'http://google.com'
      put :update, :survey_id => survey.id, :survey => {:participating_organization_ids => []}
      response.should redirect_to 'http://google.com'
      flash[:error].should_not be_nil
    end
  end
end
