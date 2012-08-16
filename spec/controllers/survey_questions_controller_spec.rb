require 'spec_helper'

describe SurveyQuestionsController do
  context "GET 'new'" do
    let(:survey) { FactoryGirl.create(:survey) }

    it "assigns the survey_question instance variable" do
      get :new, :survey_id => survey.id
      assigns(:question).should_not be_nil
    end

    it "responds with a new page" do
      get :new, :survey_id => survey.id
      response.should be_ok
      response.should render_template('new')
    end    
  end
end
