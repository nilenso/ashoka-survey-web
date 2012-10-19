require 'spec_helper'

module Api
  module V1
    describe ResponsesController do
     
      context "POST 'create'" do
        it "creates an response" do
          survey = FactoryGirl.create(:survey)
          resp = FactoryGirl.attributes_for(:response)
          expect {
            post :create, :survey_id => survey.id, :response => resp
          }.to change { Response.count }.by 1
        end

        it "creates the nested answers" do
          survey = FactoryGirl.create(:survey)
          question = FactoryGirl.create(:question)
          resp = FactoryGirl.attributes_for(:response, :survey_id => survey.id, :answers_attributes =>  { '0' => {'content' => 'asdasd', 'question_id' => question.id} })
          expect {
            post :create, :survey_id => survey.id, :response => resp
          }.to change { Answer.count }.by 1
        end

        it "should return the newly created response as JSON" do
          survey = FactoryGirl.create(:survey)
          question = FactoryGirl.create(:question)
          resp = FactoryGirl.attributes_for(:response, :survey_id => survey.id, :answers_attributes =>  { '0' => {'content' => 'asdasd', 'question_id' => question.id} })
          post :create, :response => resp
          response.should be_ok
          JSON.parse(response.body).keys.should =~ Response.new.attributes.keys
        end

        it "returns a bad request if you give a invalid response" do
          question = FactoryGirl.create(:question)
          resp = FactoryGirl.attributes_for(:response, :answers_attributes =>  { '0' => {'content' => 'asdasd', 'question_id' => question.id} })
          post :create, :response => resp
          response.should_not be_ok
          response.status.should == 400
        end
      end

      context "PUT 'update'" do
        it "updates a response" do
          survey = FactoryGirl.create(:survey)
          question = FactoryGirl.create(:question)
          resp = FactoryGirl.create(:response, :survey => survey, :organization_id => 1, :user_id => 1)
          resp_attr = { :answers_attributes =>  { '0' => {'content' => 'asdasd', 'question_id' => question.id} } }
          put :update, :id => resp.id, :response => resp_attr
          response.should be_ok
          Response.find(resp.id).answers.map(&:content).should include("asdasd")
        end

        it "returns a bad request if you give a invalid response" do
          survey = FactoryGirl.create(:survey)
          question = FactoryGirl.create(:question, :mandatory => true)
          resp = FactoryGirl.create(:response, :survey => survey, :organization_id => 1, :user_id => 1, :complete => true)
          resp_attr = { :answers_attributes =>  { '0' => {'content' => nil, 'question_id' => question.id} } }
          put :update, :id => resp.id, :response => resp_attr
          response.should_not be_ok
          response.status.should == 400
        end
      end
    end
  end
end
