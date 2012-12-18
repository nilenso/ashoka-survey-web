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

    it "assigns all the organizations" do
      get :index
      assigns(:organizations).length.should == 2
      assigns(:organizations).first.should be_a Organization
      assigns(:organizations).first.id.should == 123
      assigns(:organizations).first.name.should == "foo"
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
        @draft_survey = FactoryGirl.create(:survey, :finalized => false, :organization_id => organization_id)
        @finalized_survey = FactoryGirl.create(:survey, :finalized => true, :organization_id => organization_id)
      end


      it "shows all finalized surveys if filter is finalized" do
        get :index, :finalized => true
        response.should be_ok
        assigns(:surveys).should include @finalized_survey
        assigns(:surveys).should_not include @draft_survey
      end

      it "shows all draft surveys if filter is draft" do
        get :index, :drafts => true
        response.should be_ok
        assigns(:surveys).should include @draft_survey
        assigns(:surveys).should_not include @finalized_survey
      end

      it "shows all surveys if filter is not specified" do
        get :index
        response.should be_ok
        assigns(:surveys).should include @draft_survey
        assigns(:surveys).should include @finalized_survey
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

  context "POST 'create'" do
    before(:each) do
      sign_in_as('cso_admin')
      session[:user_info][:org_id] = 123
      @survey_attributes = FactoryGirl.attributes_for(:survey)
    end

    context "when save is unsuccessful" do
      it "redirects to the surveys build path" do
        post :create, :survey => @survey_attributes
        created_survey = Survey.find_all_by_name(@survey_attributes[:name]).last
        response.should redirect_to(survey_build_path(:survey_id => created_survey.id))
        flash[:notice].should_not be_nil
      end
    end

    context "when save is successful" do
      it "creates a survey" do
        expect { post :create,:survey => @survey_attributes }.to change { Survey.count }.by(1)
      end

      it "assigns the organization id of the current user to the survey" do
        post :create, :survey => @survey_attributes
        created_survey = Survey.find_all_by_name(@survey_attributes[:name]).last
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
      get :build, :survey_id => @survey.id
      response.should render_template(:build)
    end

    it "redirect_to the root path if survey is already finalized" do
      @survey.finalize
      get :build, :survey_id => @survey.id
      response.should redirect_to(root_path)
      flash[:error].should_not be_nil
    end
  end

  context "when finalizing" do
    before(:each) do
      sign_in_as('cso_admin')
      @survey = FactoryGirl.create(:survey)
    end

    it "finalizes the survey" do
      put :finalize, :survey_id => @survey.id
      @survey.reload.should be_finalized
    end

    it "redirects to the publish to users page" do
      put :finalize, :survey_id => @survey.id
      response.should redirect_to edit_survey_publication_path
    end

    it "shows a flash message saying the survey was finalized" do
      put :finalize, :survey_id => @survey.id
      flash.notice.should_not be_nil
    end
  end

  context "POST 'duplicate'" do
    before(:each) do
      sign_in_as('cso_admin')
      session[:user_info][:org_id] = 123
      request.env["HTTP_REFERER"] = 'http://google.com'
    end

    it "creates a new survey" do
      survey = FactoryGirl.create :survey, :organization_id => 123
      expect {
        post :duplicate, :id => survey.id
      }.to change { Survey.count }.by 1
    end

    it "redirects to previous page" do
      survey = FactoryGirl.create :survey, :organization_id => 123
      request.env["HTTP_REFERER"] = 'http://google.com'
      post :duplicate, :id => survey.id
      response.should redirect_to request.env['HTTP_REFERER']
      flash[:notice].should_not be_nil
    end
  end

  context "GET 'report'" do
    before(:each) do
      sign_in_as('cso_admin')
      session[:user_info][:org_id] = 123
    end

    it "renders the `report` template" do
      survey = FactoryGirl.create :survey, :organization_id => 123
      get :report, :id => survey.id
      response.should render_template :report
    end

    it "assigns the survey for the view" do
      survey = FactoryGirl.create :survey, :organization_id => 123
      get :report, :id => survey.id
      assigns(:survey).should be_true
    end
  end
end
