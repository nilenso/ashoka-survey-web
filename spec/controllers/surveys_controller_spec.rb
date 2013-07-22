require 'spec_helper'

describe SurveysController do
  render_views

  context "GET 'index'" do
    before(:each) do
      request.env['HTTPS'] = 'on'
      session[:access_token] = "123"
      response = mock(OAuth2::Response)
      access_token = mock(OAuth2::AccessToken)
      controller.stub(:access_token).and_return(access_token)
      access_token.stub(:get).and_return(response)
      response.stub(:parsed).and_return([
        {"id" => 123, "name" => "foo", "logos" => {"thumb_url" => "http://foo.png"}},
        {"id" => LOGGED_IN_ORG_ID, "name" => "bar", "logos" => {"thumb_url" => "http://foo.png"}}
      ])
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
      before(:each) do
        sign_in_as('cso_admin')
        @draft_survey = FactoryGirl.create(:survey, :finalized => false, :organization_id => LOGGED_IN_ORG_ID)
        @finalized_survey = FactoryGirl.create(:survey, :finalized, :organization_id => LOGGED_IN_ORG_ID)
        @archived_survey = FactoryGirl.create(:survey, :archived, :organization_id => LOGGED_IN_ORG_ID)
      end

      it "shows all draft surveys if filter is draft" do
        get :index, :filter => "drafts"
        response.should be_ok
        assigns(:surveys).should == [@draft_survey]
      end

      it "shows all draft surveys if filter is archived" do
        get :index, :filter => "archived"
        response.should be_ok
        assigns(:surveys).should == [@archived_survey]
      end

      it "shows active surveys if filter is not specified" do
        get :index
        response.should be_ok
        assigns(:surveys).should include @finalized_survey
      end
    end

    it "shows surveys in the most recently published order" do
      sign_in_as('cso_admin')
      oldest_survey = Timecop.freeze(2.days.from_now) { FactoryGirl.create(:survey, :finalized, :expiry_date => 2.days.from_now, :organization_id => LOGGED_IN_ORG_ID) }
      old_survey = Timecop.freeze(1.week.from_now) { FactoryGirl.create(:survey, :finalized, :expiry_date => 2.days.from_now, :organization_id => LOGGED_IN_ORG_ID) }
      new_survey = Timecop.freeze(2.weeks.from_now) { FactoryGirl.create(:survey, :finalized, :expiry_date => 2.days.from_now, :organization_id => LOGGED_IN_ORG_ID) }
      get :index
      assigns(:surveys).map(&:id).should == [new_survey, old_survey, oldest_survey].map(&:id)
    end

    context "when redirecting to a https:// url" do
      it "redirects if the request is http://" do
        request.env['HTTPS'] = 'off'
        get :index
        response.should be_a_redirect
        URI(response.location).scheme.should == "https"
      end

      it "doesn't redirect if the request is a HEAD request" do
        request.env['HTTPS'] = 'off'
        head :index
        response.should_not be_a_redirect
      end
    end
  end

  context "DELETE 'destroy'" do
    let!(:survey) { FactoryGirl.create(:survey, :organization_id => LOGGED_IN_ORG_ID) }

    before(:each) do
      sign_in_as('cso_admin')
    end

    it "deletes a survey" do
      expect { delete :destroy, :id => survey.id }.to change { Survey.count }.by(-1)
      flash[:notice].should_not be_nil
    end

    it "doesn't delete any other surveys" do
      other_survey = FactoryGirl.create(:survey)
      delete :destroy, :id => survey.id
      other_survey.reload.should be_present
    end

    it "redirects to the survey index page" do
      delete :destroy, :id => survey.id
      response.should redirect_to surveys_path
    end

    it "sends an event to mixpanel" do
      expect do
        delete :destroy, :id => survey.id
      end.to change { Delayed::Job.count }.by(1)
    end

    it "doesn't delete the survey if it has any non-blank responses" do
      FactoryGirl.create(:response, :survey => survey, :blank => false)
      expect do
        delete :destroy, :id => survey.id
      end.not_to change { Survey.count }
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

    it "sends an event to mixpanel" do
      expect do
        post :create
      end.to change { Delayed::Job.count }.by(1)
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

    it "loads up even if the survey is finalized" do
      @survey.finalize
      get :build, :survey_id => @survey.id
      response.should be_ok
      flash[:error].should be_nil
    end
  end

  context "PUT finalize" do
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
      response.should redirect_to edit_survey_publication_path(@survey.id)
    end

    it "shows a flash message saying the survey was finalized" do
      put :finalize, :survey_id => @survey.id
      flash.notice.should_not be_nil
    end

    it "sends an event to mixpanel" do
      expect do
        post :finalize, :survey_id => @survey.id
      end.to change { Delayed::Job.count }.by(1)
    end
  end

  context "PUT archive" do
    before(:each) do
      sign_in_as('cso_admin')
      session[:user_info][:org_id] = 123
      @survey = FactoryGirl.create(:survey, :finalized, :organization_id => 123)
    end

    it "archives the survey" do
      put :archive, :survey_id => @survey.id
      @survey.reload.should be_archived
    end

    it "redirects to the root page" do
      put :archive, :survey_id => @survey.id
      response.should redirect_to root_path
    end

    it "shows a flash message saying the survey was archived" do
      put :archive, :survey_id => @survey.id
      flash.notice.should_not be_nil
    end

    it "shows a flash error when trying to archive an archived survey" do
      put :archive, :survey_id => @survey.id
      put :archive, :survey_id => @survey.id
      flash[:error].should_not be_nil
    end

    it "sends an event to mixpanel" do
      expect do
        post :archive, :survey_id => @survey.id
      end.to change { Delayed::Job.count }.by(1)
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

    it "assigns the completed responses count" do
      survey = FactoryGirl.create(:survey, :organization_id => 123)
      response = FactoryGirl.create(:response, :survey => survey, :status => "complete")
      get :report, :id => survey.id
      assigns(:complete_responses_count).should == 1
    end
  end
end
