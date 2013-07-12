require 'spec_helper'

describe ResponsesDashboardController do
  describe "GET 'index'"  do
    it "renders the 'index' template" do
      survey = FactoryGirl.create(:survey)
      get :index, :survey_id => survey.id
      response.should be_ok
      response.should render_template :index
    end

    it "assigns the IDs of users who have taken responses for the survey" do
      survey = FactoryGirl.create(:survey)
      response = FactoryGirl.create(:response, :user_id => 5, :survey => survey)
      get :index, :survey_id => survey.id
      assigns(:ids_for_users_with_responses).should == [5]
    end

    it "raises an error if the survey ID is invalid" do
      expect { get :index, :survey_id => 42 }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe "GET 'show'" do
    it "renders the 'show' template" do
      survey = FactoryGirl.create(:survey)
      get :show, :survey_id => survey.id, :id => 42
      response.should be_ok
      response.should render_template :show
    end

    it "assigns the survey whose ID is passed in" do
      survey = FactoryGirl.create(:survey)
      get :show, :survey_id => survey.id, :id => 42
      assigns(:survey).should == survey
    end

    it "assigns the user ID that it was passed" do
      survey = FactoryGirl.create(:survey)
      get :show, :survey_id => survey.id, :id => 42
      assigns(:user_id).should == 42
    end

    it "raises an error if the survey ID is invalid" do
      expect { get :show, :survey_id => 42, :id => 42 }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
