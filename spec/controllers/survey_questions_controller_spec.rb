require 'spec_helper'

describe SurveyQuestionsController do
  context "POST 'create'" do

    context "when save is successful" do
      let!(:survey_question) { FactoryGirl.attributes_for(:survey_question) }
      let!(:survey) { FactoryGirl.create(:survey) }

      it "assigns the question instance variable" do
        post :create, :survey_question => survey_question, :survey_id => survey.id
        assigns(:survey_question).should_not be_nil
      end

      it "redirects to the root page" do
        post :create, :survey_question => survey_question, :survey_id => survey
        response.should redirect_to(:root)
        flash[:notice].should_not be_nil
      end

      it "creates a survey" do
        expect do 
          post :create, :survey_question => survey_question, :survey_id => survey 
        end.to change { SurveyQuestion.count }.by(1)
      end
    end
  end
end
