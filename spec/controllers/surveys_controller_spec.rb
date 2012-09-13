require 'spec_helper'

describe SurveysController do
  render_views

  context "GET 'index'" do
    it "assigns the surveys instance variable" do
      get :index
      assigns(:surveys).should_not be_nil
    end

    it "responds with the index page" do
      get :index
      response.should be_ok
      response.should render_template(:index)
    end

    context "when filtering" do
      before(:each) do
        Survey.delete_all
        @unpublished_survey = FactoryGirl.create(:survey, :published => false)
        @published_survey = FactoryGirl.create(:survey, :published => true)
      end

      it "shows all published surveys if filter is published" do
        get :index, :published => true
        response.should be_ok
        assigns(:surveys).should include @published_survey
        assigns(:surveys).should_not include @unpublished_survey
      end

      it "shows all unpublished surveys if filter is unpublished" do
        get :index, :published => false
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
    it "assigns the survey instance variable" do
      session[:user_info] = { :role => 'cso_admin'}
      get :new
      assigns(:survey).should_not be_nil
    end

    context "allows only a CSO admin to create a survey" do
      it "does not let a user create a survey" do
        session[:user_info] = { :role => 'user'}
        post :create, :survey => @survey_attributes
        response.should redirect_to surveys_path
        flash[:error].should_not be_nil
      end

      it "does not let an admin create a survey" do
        session[:user_info] = { :role => 'admin'}
        post :create, :survey => @survey_attributes
        response.should redirect_to surveys_path
        flash[:error].should_not be_nil
      end
    end
  end

  context "POST 'create'" do
    context "when save is unsuccessful" do
      before(:each) do
        @survey_attributes = FactoryGirl.attributes_for(:survey)
        session[:user_info] = { :org_id => 123, :role => 'cso_admin' }
      end

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
        session[:user_info] = { :org_id => 123, :role => 'cso_admin' }
        post :create, :surveys => { :name => "" }
        response.should be_ok
        response.should render_template(:new)
      end
    end
  end

  context "GET 'build'" do
    it "renders the 'build' template" do
      survey = FactoryGirl.create(:survey)
      get :build, :id => survey.id
      response.should render_template(:build)
    end
  end

  context "PUT 'publish'" do
    it "changes the status of a survey from unpublished to published" do
      survey = FactoryGirl.create(:survey)
      put :publish, :survey_id => survey.id
      response.should redirect_to(surveys_path)
      flash[:notice].should_not be_nil
      Survey.find(survey.id).should be_published
    end
  end
  context "PUT 'unpublish'" do
    it "changes the status of a survey from published to unpublished" do
      survey = FactoryGirl.create(:survey, :published => true)
      put :unpublish, :survey_id => survey.id
      response.should redirect_to(surveys_path)
      flash[:notice].should_not be_nil
      Survey.find(survey.id).should_not be_published
    end
  end
end
