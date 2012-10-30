require 'spec_helper'

module Api
  module V1
    describe ResponsesController do

      context "POST 'create'" do
        let (:survey) { FactoryGirl.create(:survey) }
        let (:question) { FactoryGirl.create(:question) }

        it "creates an response" do
          resp = FactoryGirl.attributes_for(:response, :survey_id => survey.id, :answers_attributes =>{})
          expect {
            post :create, :response => resp
          }.to change { Response.count }.by 1
        end

        it "creates the nested answers" do
          resp = FactoryGirl.attributes_for(:response, :survey_id => survey.id, :answers_attributes =>  { '0' => {'content' => 'asdasd', 'question_id' => question.id} })
          expect {
            post :create, :survey_id => survey.id, :response => resp
          }.to change { Answer.count }.by 1
        end

        it "should return the newly created response with answers as JSON if it is incomplete" do
          resp = FactoryGirl.attributes_for(:response, :survey_id => survey.id, :answers_attributes =>  { '0' => {'content' => 'asdasd', 'question_id' => question.id} })
          post :create, :response => resp
          response.should be_ok
          JSON.parse(response.body).keys.should =~ Response.new.attributes.keys.unshift("answers")
        end

        it "should not return the newly created response if it is complete" do
          resp = FactoryGirl.attributes_for(:response, :survey_id => survey.id, :status => 'complete', :answers_attributes =>  { '0' => {'content' => 'asdasd', 'question_id' => question.id} })
          post :create, :response => resp
          response.should be_ok
          response.body.should be_blank
        end

        it "should not create the response and should return it with answers if it fails the validation" do
          question = FactoryGirl.create(:question, :type => 'SingleLineQuestion', :mandatory => true)
          resp = FactoryGirl.attributes_for(:response, :survey_id => survey.id, :status => 'complete', :answers_attributes =>  { '0' => {'content' => "", 'question_id' => question.id} })
          expect {
            post :create, :response => resp
          }.to change {Response.count}.by 0
          response.should_not be_ok
          response.status.should == 400
          JSON.parse(response.body).keys.should =~ Response.new.attributes.keys.unshift("answers")
        end

        it "returns the response with a bad_request if you give a invalid response" do
          resp = FactoryGirl.attributes_for(:response, :survey => nil, :answers_attributes =>  { '0' => {'content' => 'asdasd', 'question_id' => question.id} })
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
          resp_attr = { :answers_attributes =>  { '0' => {'content' => 'asdasd', 'question_id' => question.id, 'updated_at' => Time.now.to_s} } }
          put :update, :id => resp.id, :response => resp_attr
          response.should be_ok
          Response.find(resp.id).answers.map(&:content).should include("asdasd")
        end

        it "returns a bad request if you give a invalid response" do
          survey = FactoryGirl.create(:survey)
          question = FactoryGirl.create(:question, :mandatory => true)
          resp = FactoryGirl.create(:response, :survey => survey, :organization_id => 1, :user_id => 1, :status => 'complete')
          resp_attr = { :answers_attributes =>  { '0' => {'content' => nil, 'question_id' => question.id } } }
          put :update, :id => resp.id, :response => resp_attr
          response.should_not be_ok
          response.status.should == 400
        end

        it "updates only the answers which are newer than their corresponding answers in the DB" do
          survey = FactoryGirl.create(:survey)
          question_1 = FactoryGirl.create(:question)
          question_2 = FactoryGirl.create(:question)
          resp = FactoryGirl.create(:response, :survey => survey, :organization_id => 1, :user_id => 1)
          resp.answers << FactoryGirl.create(:answer, :question_id => question_1.id)
          resp.answers << FactoryGirl.create(:answer, :question_id => question_2.id)
          resp_attr = { :answers_attributes =>
                            { '0' => {'content' => 'newer', 'question_id' => question_1.id, 'updated_at' => 5.hours.from_now.to_s, 'id' => resp.answers.first.id},
                              '1' => {'content' => 'older', 'question_id' => question_2.id, 'updated_at' => 5.hours.ago.to_s, 'id' => resp.answers.last.id }} }
          put :update, :id => resp.id, :response => resp_attr
          resp.reload.answers.map(&:content).should include 'newer'
          resp.reload.answers.map(&:content).should_not include 'older'
        end
      end
    end
  end
end
