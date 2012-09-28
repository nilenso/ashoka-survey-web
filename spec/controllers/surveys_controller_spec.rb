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

    it "requires cso_admin for Deleting a survey" do
      sign_in_as('user')
      delete :destroy, :id => survey.id
      response.should redirect_to(surveys_path)
      flash[:error].should_not be_empty
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

    it "requires cso_admin for creating a survey" do
      sign_in_as('user')
      get :new
      response.should redirect_to(surveys_path)
      flash[:error].should_not be_empty
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

    it "requires cso_admin for creating a survey" do
      sign_in_as('user')
      post :create, :survey => @survey_attributes
      response.should redirect_to(surveys_path)
      flash[:error].should_not be_empty
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
    end

    context "when save is unsuccessful" do
      it "renders the new page" do
        post :create, :surveys => { :name => "" }
        response.should be_ok
        response.should render_template(:new)
      end
    end
  end

  context "GET 'build'" do
    before(:each) do
      sign_in_as('cso_admin')
      @survey = FactoryGirl.create(:survey)
    end

    it "requires cso_admin for building a survey" do
      pending
      sign_in_as('user')
      get :build, :id => @survey.id
      response.should redirect_to(surveys_path)
      flash[:error].should_not be_empty
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

  context "GET 'publish'" do
    before(:each) do
      request.env["HTTP_REFERER"] = 'http://google.com'
      sign_in_as('cso_admin')
      @survey = FactoryGirl.create(:survey)
      session[:access_token] = "123"
      response = mock(OAuth2::Response)
      access_token = mock(OAuth2::AccessToken)
      controller.stub(:access_token).and_return(access_token)
      access_token.stub(:get).and_return(response)
      response.stub(:parsed).and_return([{"id" => 123, "name" => "user"}])
    end

    it "requires cso_admin for publishing a survey" do
      sign_in_as('user')
      get :publish, :survey_id => @survey.id
      response.should redirect_to surveys_path
      flash[:error].should_not be_empty
    end

    it "redirects back to the previous page" do
      request.env["HTTP_REFERER"] = 'http://google.com'
      get :publish, :survey_id => @survey.id
      response.should redirect_to 'http://google.com'
    end

    it "publishes the survey" do
      get :publish, :survey_id => @survey.id
      @survey.reload.should be_published
    end
  end
end
