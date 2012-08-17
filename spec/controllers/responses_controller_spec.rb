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

    it "assigns the appropriate survey" do
      get :new, :survey_id => survey.id
      assigns(:survey).should == survey
    end

    it "assigns new answers to the response corresponding to the survey questions" do
      get :new, :survey_id => survey.id
      assigns(:response).answers.size.should == survey.questions.size
      assigns(:response).answers.each { |answer| answer.should be_an Answer }
    end
  end

  context "POST 'create'" do
    let(:response) { FactoryGirl.attributes_for(:response_with_answers)}

    it "sets the response instance variable" do
      post :create, :response => response, :survey_id => survey.id
      assigns(:response).should_not be_nil
    end

    context "when save is successful" do
      it "saves the response" do
        expect do
          post :create, :response => response, :survey_id => survey.id
        end.to change { Response.count }.by(1)
      end

      it "saves the response to the right survey" do
        post :create, :response => response, :survey_id => survey.id
        assigns(:response).survey.should ==  survey
      end

      it "redirects to the root path" do
        post :create, :response => response, :survey_id => survey.id          
        response.should redirect_to root_path
      end
    end
  end
end
