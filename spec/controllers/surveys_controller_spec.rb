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

  # Temp route while we're porting to backbone

  context "GET 'new" do
    it "assigns the survey instance variable" do
      get :new
      assigns(:survey).should_not be_nil
    end
  end
  
  context "POST 'create'" do
    context "when save is unsuccessful" do
      before(:each) do
        @survey_attributes = FactoryGirl.attributes_for(:survey)
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
    it "renders the 'build' template" do
      survey = FactoryGirl.create(:survey)
      get :build, :id => survey.id
      response.should render_template(:build)
    end
  end
end
