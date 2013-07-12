require 'spec_helper'

describe ResponsesDashboardController do
  describe "GET 'show'" do
    it "renders the 'show' template" do
      survey = FactoryGirl.create(:survey)
      get :show, :survey_id => survey.id
      response.should be_ok
      response.should render_template :show
    end

    it "assigns the survey whose ID is passed in" do
      survey = FactoryGirl.create(:survey)
      get :show, :survey_id => survey.id
      assigns(:survey).should == survey
    end

    it "assigns the current user ID" do
      survey = FactoryGirl.create(:survey)
      session[:user_id] = 42
      get :show, :survey_id => survey.id
      assigns(:current_user_id).should == 42
    end

    it "raises an error if the survey ID is invalid" do
      expect { get :show, :survey_id => 42 }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
