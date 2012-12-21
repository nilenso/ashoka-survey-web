require 'spec_helper'

describe PublicationsController do
  render_views

  let(:survey) { FactoryGirl.create(:survey, :organization_id => LOGGED_IN_ORG_ID, :finalized => true) }

  before(:each) do
    sign_in_as('cso_admin')
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
  end

  context "PUT 'update'" do
    before(:each) do
      request.env["HTTP_REFERER"] = 'http://google.com'
    end

    it "updates the expiry date of the survey" do
      new_expiry_date = survey.expiry_date + 1.day
      put :update, :survey_id => survey.id, :survey => {:expiry_date => new_expiry_date, :user_ids => [1, 2]}
      response.should redirect_to surveys_path
      survey.reload.expiry_date.should == new_expiry_date
    end

    it "makes the survey public" do
      put :update, :survey_id => survey.id, :survey => {:expiry_date => survey.expiry_date, :public => true}
      survey.reload.should be_public
    end

    it "redirects to the previous page with an error if the validation fails" do
      put :update, :survey_id => survey.id, :survey => {:expiry_date => "bad_expiry_date", :user_ids => [1, 2]}
      response.should redirect_to "http://google.com"
    end

    it "publishes the survey to chosen users" do
      put :update, :survey_id => survey.id, :survey => {:user_ids => [1, 2], :expiry_date => survey.expiry_date}
      survey.reload.user_ids.should == [1, 2]
      flash[:notice].should_not be_nil
    end

    it "updates the list of shared organizations" do
      participating_organizations = [12, 45]
      put :update, :survey_id => survey.id, :survey => { :participating_organization_ids => participating_organizations, :expiry_date => survey.expiry_date}
      survey.participating_organizations.map(&:organization_id).should == [12, 45]
    end

    context " if the expiry date is invalid" do
      it "doesn't publish the survey to chosen users" do
        put :update, :survey_id => survey.id, :survey => {:user_ids => [1, 2], :expiry_date => Date.yesterday}
        survey.reload.user_ids.should_not == [1, 2]
      end

      it "doesn't update the list of shared organizations" do
        participating_organizations = [12, 45]
        put :update, :survey_id => survey.id, :survey => { :participating_organization_ids => participating_organizations, :expiry_date => Date.yesterday}
        survey.participating_organizations.map(&:organization_id).should_not == [12, 45]
      end
    end

    context "when users or organizations are not selected" do
      it "redirects back to the edit page with an error when no user ids or organization ids are selected" do
        put :update, :survey_id => survey.id, :survey => {:user_ids => [], :participating_organizations_ids => [], :expiry_date => survey.expiry_date}
        response.should redirect_to 'http://google.com'
        flash[:error].should_not be_nil
      end

      it "does not redirect back to the previous page when only organizations are selected" do
        put :update, :survey_id => survey.id, :survey => {:participating_organization_ids => [1, 2], :user_ids => [], :expiry_date => survey.expiry_date}
        response.should_not redirect_to 'http://google.com'
        flash[:error].should be_nil
      end

      it "does not redirect back to the previous page when only users are selected" do
        put :update, :survey_id => survey.id, :survey => {:participating_organization_ids => [], :user_ids => [1, 2], :expiry_date => survey.expiry_date}
        response.should_not redirect_to 'http://google.com'
        flash[:error].should be_nil
      end

      context "does not require users or organizations to be selected" do
        it "when the survey is already published" do
          survey.publish_to_users([1, 2])
          put :update, :survey_id => survey.id, :survey => {:expiry_date => survey.expiry_date}
          response.should_not redirect_to 'http://google.com'
          flash[:error].should be_nil
        end

        it "when the survey is marked public" do
          put :update, :survey_id => survey.id, :survey => {:expiry_date => survey.expiry_date, :public => true}
          response.should_not redirect_to 'http://google.com'
          flash[:error].should be_nil
        end
      end
    end

    it "redirects to the list of surveys" do
      put :update, :survey_id => survey.id, :survey => {:participating_organization_ids => [1, 2], :user_ids => [1, 2], :expiry_date => survey.expiry_date}
      response.should redirect_to surveys_path
    end
  end
end
