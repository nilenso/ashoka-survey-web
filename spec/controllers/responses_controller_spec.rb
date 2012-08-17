require 'spec_helper'

describe ResponsesController do
  let(:survey) { FactoryGirl.create(:survey_with_questions) }

  context "GET 'new'" do
    it "renders a page to create a new response" do
      get :new, :survey_id => survey.id
      response.should be_ok
      response.should render_template(:new)
    end

    it "assigns a new response" do
      get :new, :survey_id => survey.id
      assigns(:response).should_not be_nil
    end

    it "assigns the appropriate questions" do
      get :new, :survey_id => survey.id
      assigns(:questions).should == survey.questions
    end

    it "assigns the appropriate questions" do
      get :new, :survey_id => survey.id
      assigns(:survey).should == survey
    end
  end
end
