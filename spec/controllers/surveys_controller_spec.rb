require 'spec_helper'

describe SurveysController do
  render_views

  context "GET 'index'" do
    before(:each) do
      session[:access_token] = "123"
      response = mock(OAuth2::Response)
      access_token = mock(OAuth2::AccessToken)
      controller.stub(:access_token).and_return(access_token)
      access_token.stub(:get).and_return(response)
      response.stub(:parsed).and_return([{"id" => 123, "name" => "foo"}, {"id" => 12, "name" => "bar"}])
    end

    it "assigns the surveys instance variable" do
      get :index
      assigns(:surveys).should_not be_nil
    end

    it "assigns a hash of organization_ids mapped to their names" do
      get :index
      assigns(:organization_names).should == { 123 => "foo", 12 => "bar" }
    end

    it "responds with the index page" do
      get :index
      response.should be_ok
      response.should render_template(:index)
    end

    context "when filtering" do
      let(:organization_id) { 12 }

      before(:each) do
        Survey.delete_all
        sign_in_as('cso_admin')
        session[:user_info][:org_id] = organization_id
        @unpublished_survey = FactoryGirl.create(:survey, :published => false, :organization_id => organization_id)
        @published_survey = FactoryGirl.create(:survey, :published => true, :organization_id => organization_id)
      end


      it "shows all published surveys if filter is published" do
        get :index, :published => "true"
        response.should be_ok
        assigns(:surveys).should include @published_survey
        assigns(:surveys).should_not include @unpublished_survey
      end

      it "shows all unpublished surveys if filter is unpublished" do
        get :index, :published => "false"
        response.should be_ok
        assigns(:surveys).should include @unpublished_survey
        assigns(:surveys).should_not include @published_survey
      end

      it "shows all surveys if filter is not specified" do
        get :index
        response.should be_ok
        assigns(:surveys).should include @unpublished_survey
        assigns(:surveys).should include @published_survey
      end
    end
  end

  context "DELETE 'destroy'" do
    let!(:survey) { FactoryGirl.create(:survey) }
    before(:each) do
      sign_in_as('cso_admin')
    end

    it "deletes a survey" do
      expect { delete :destroy, :id => survey.id }.to change { Survey.count }.by(-1)
      flash[:notice].should_not be_nil
    end

    it "redirects to the survey index page" do
      delete :destroy, :id => survey.id
      response.should redirect_to surveys_path
    end
  end

  context "GET 'new" do
    before(:each) do
      sign_in_as('cso_admin')
    end

    it "assigns the survey instance variable" do
      get :new
      assigns(:survey).should_not be_nil
    end
  end

  context "POST 'create'" do
    before(:each) do
      sign_in_as('cso_admin')
      session[:user_info][:org_id] = 123
      @survey_attributes = FactoryGirl.attributes_for(:survey)
    end

    context "when save is unsuccessful" do
      it "redirects to the surveys build path" do
        post :create, :survey => @survey_attributes
        created_survey = Survey.find_last_by_name(@survey_attributes[:name])
        response.should redirect_to(surveys_build_path(:id => created_survey.id))
        flash[:notice].should_not be_nil
      end

      it "creates a survey" do
        expect { post :create,:survey => @survey_attributes }.to change { Survey.count }.by(1)
      end

      it "assigns the organization id of the current user to the survey" do
        post :create, :survey => @survey_attributes
        created_survey = Survey.find_last_by_name(@survey_attributes[:name])
        created_survey.organization_id.should == session[:user_info][:org_id]
      end

      it "creates a survey with placeholder attrs if params[:survey] doesn't exist" do
        expect { post :create }.to change { Survey.count }.by(1)
      end
    end
  end

  context "GET 'build'" do
    before(:each) do
      sign_in_as('cso_admin')
      @survey = FactoryGirl.create(:survey)
    end

    it "renders the 'build' template" do
      get :build, :id => @survey.id
      response.should render_template(:build)
    end

    it "redirect_to the root path if survey is already published" do
      @survey.publish
      get :build, :id => @survey.id
      response.should redirect_to(root_path)
      flash[:error].should_not be_nil
    end
  end

  context "when publishing" do
    let(:survey) { FactoryGirl.create(:survey, :organization_id => 1) }

    before(:each) do
      sign_in_as('cso_admin')
      session[:user_info][:org_id] = 1

      session[:access_token] = "123"
      users_response = mock(OAuth2::Response)
      access_token = mock(OAuth2::AccessToken)
      controller.stub(:access_token).and_return(access_token)

      access_token.stub(:get).with('/api/organizations/1/users').and_return(users_response)
      users_response.stub(:parsed).and_return([{"id" => 1, "name" => "Bob"}, {"id" => 2, "name" => "John"}])
    end

    context "GET 'publish to users'" do
      it "assigns shared and unshared users in the current organization" do
        survey.survey_users << FactoryGirl.create(:survey_user, :user_id => 1, :survey_id => survey.id)
        get :publish_to_users, :survey_id => survey.id
        assigns(:shared_users).map{ |user| {:id => user.id, :name => user.name} }
        .should include({:id=>1, :name=>"Bob"})
        assigns(:unshared_users).map{ |user| {:id => user.id, :name => user.name} }
        .should include({:id=>2, :name=>"John"})
      end

      it "assigns current survey" do
        get :publish_to_users, :survey_id => survey.id
        assigns(:survey).should == survey
      end
    end

    context "PUT 'update_publish_to_users'" do
      it "publishes the survey to chosen users and marks the survey published" do
        put :update_publish_to_users, :survey_id => survey.id, :survey => {:user_ids => [1, 2]}
        survey.reload.should be_published
        survey.user_ids.should == [1, 2]
        flash[:notice].should_not be_nil
      end

      it "redirects back to the surveys page" do
        get :update_publish_to_users, :survey_id => survey.id, :survey => {:user_ids => [1, 2]}
        response.should redirect_to surveys_path
      end

      it "redirects back to the previous page with an error when no user ids are selected" do
        request.env["HTTP_REFERER"] = 'http://google.com'
        get :update_publish_to_users, :survey_id => survey.id, :survey => {:user_ids => []}
        response.should redirect_to 'http://google.com'
        flash[:error].should_not be_nil
      end
    end
  end

  context "when sharing surveys with other organizations" do
    let(:survey) { FactoryGirl.create(:survey, :organization_id => 1) }

    before(:each) do
      sign_in_as('cso_admin')
      session[:user_info][:org_id] = 1
      survey.publish

      session[:access_token] = "123"
      orgs_response = mock(OAuth2::Response)
      access_token = mock(OAuth2::AccessToken)
      controller.stub(:access_token).and_return(access_token)

      access_token.stub(:get).with('/api/organizations').and_return(orgs_response)
      orgs_response.stub(:parsed).and_return([{"id" => 1, "name" => "CSOOrganization"}, {"id" => 2, "name" => "Ashoka"}, {"id" => 3, "name" => "FooOrganization"} ])
    end

    context "GET 'share with organizations'" do
      it "assigns shared and unshared organizations" do
        survey.participating_organizations << FactoryGirl.create(:participating_organization, :organization_id => 2, :survey_id => survey.id)
        get :share_with_organizations, :survey_id => survey.id
        assigns(:shared_organizations).map{ |org| {:id => org.id, :name => org.name} }
        .should include({:id=>2, :name=>"Ashoka"})
        assigns(:unshared_organizations).map{ |org| {:id => org.id, :name => org.name} }
        .should include({:id=>3, :name=>"FooOrganization"})
      end

      it "assigns current survey" do
        get :share_with_organizations, :survey_id => survey.id
        assigns(:survey).should == survey
      end

      it "does not allow sharing of unpublished surveys" do
        unpublished_survey = FactoryGirl.create(:survey, :organization_id => 1)
        get :share_with_organizations, :survey_id => unpublished_survey.id
        response.should redirect_to surveys_path
        flash[:error].should_not be_empty
      end
    end

    context "PUT 'update_share_with_organizations'" do
      it "updates the list of shared organizations" do
        participating_organizations = [12, 45]
        put :update_share_with_organizations, :survey_id => survey.id, :survey => { :participating_organization_ids => participating_organizations }
        survey.participating_organizations.map(&:organization_id).should == [12, 45]
      end

      it "redirects back to the surveys page" do
        put :update_share_with_organizations, :survey_id => survey.id, :survey => {:participating_organization_ids => [1, 2]}
        response.should redirect_to surveys_path
      end

      it "redirects back to the previous page with an error when no organizations are selected" do
        request.env["HTTP_REFERER"] = 'http://google.com'
        put :update_share_with_organizations, :survey_id => survey.id, :survey => {:participating_organization_ids => []}
        response.should redirect_to 'http://google.com'
        flash[:error].should_not be_nil
      end
    end
  end
end
