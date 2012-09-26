require 'spec_helper'

module Api
  module V1
    describe ResponsesController do
      context "POST 'create'" do
        it "creates an response" do
          survey = FactoryGirl.create(:survey)
          response = FactoryGirl.attributes_for(:response)
          expect {
            post :create, :survey_id => survey.id, :reponse => response
          }.to change { Response.count }.by 1
        end

        it "creates the nested answers" do
          survey = FactoryGirl.create(:survey)
          question = FactoryGirl.create(:question)
          response = FactoryGirl.attributes_for(:response, :answers_attributes =>  { '0' => {'content' => 'asdasd', 'question_id' => question.id} })
          expect {
            post :create, :survey_id => survey.id, :response => response
          }.to change { Answer.count }.by 1
        end

        it "should return the newly created response as JSON" do
          survey = FactoryGirl.create(:survey)
          question = FactoryGirl.create(:question)
          resp = FactoryGirl.attributes_for(:response, :answers_attributes =>  { '0' => {'content' => 'asdasd', 'question_id' => question.id} })
          post :create, :survey_id => survey.id, :reponse => resp
          response.should be_ok
          JSON.parse(response.body).keys.should =~ Response.new.attributes.keys
        end
      end
    end
  end
end
