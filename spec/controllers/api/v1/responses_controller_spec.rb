require 'spec_helper'

module Api
  module V1
    describe ResponsesController do
      let(:organization_id) { 12 }

      before(:each) do
        sign_in_as('cso_admin')
        session[:user_info][:org_id] = organization_id
        response = double('response')
        parsed_response = { "email" => "admin@admin.com",
                            "id" => 1,
                            "name" => "cso_admin",
                            "organization_id" => 12,
                            "role" => "cso_admin"
                            }

        access_token = double('access_token')
        OAuth2::AccessToken.stub(:new).and_return(access_token)
        access_token.stub(:get).and_return(response)
        response.stub(:parsed).and_return(parsed_response)
      end

      context "POST 'create'" do
        let! (:survey) { FactoryGirl.create(:survey, :organization_id => organization_id, :expiry_date => Date.tomorrow) }
        let (:question) { FactoryGirl.create(:question) }

        it "creates an response" do
          resp = FactoryGirl.attributes_for(:response, :survey_id => survey.id, :answers_attributes =>{})
          expect {
            post :create, :response => resp, :survey_id => survey.id
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
          post :create, :response => resp, :survey_id => survey.id
          response.should be_ok
          JSON.parse(response.body).keys.should =~ Response.new.attributes.keys.unshift("answers")
        end

        it "should return the newly created response if it is complete" do
          resp = FactoryGirl.attributes_for(:response, :survey_id => survey.id, :status => 'complete', :answers_attributes =>  { '0' => {'content' => 'asdasd', 'question_id' => question.id} })
          post :create, :response => resp, :survey_id => survey.id
          response.should be_ok
          JSON.parse(response.body).keys.should =~ Response.new.attributes.keys.unshift("answers")
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

        it "returns response with a bad request if survey is expired" do
          survey = FactoryGirl.create(:survey, :organization_id => organization_id)
          survey.update_attribute('expiry_date', Date.yesterday)
          resp = FactoryGirl.attributes_for(:response, :survey_id => survey.id, :answers_attributes =>{})
          post :create, :response => resp
          response.should_not be_ok
          response.status.should == 400
        end
      end

      context "PUT 'update'" do
        it "updates a response" do
          survey = FactoryGirl.create(:survey, :organization_id => organization_id)
          question = FactoryGirl.create(:question)
          resp = FactoryGirl.create(:response, :survey => survey, :organization_id => organization_id, :user_id => 1)
          resp_attr = { :answers_attributes =>  { '0' => {'content' => 'asdasd', 'question_id' => question.id, 'updated_at' => Time.now.to_s} } }
          put :update, :id => resp.id, :response => resp_attr, :survey_id => survey.id
          response.should be_ok
          Response.find(resp.id).answers.map(&:content).should include("asdasd")
        end

        it "returns a bad request if you give a invalid response" do
          survey = FactoryGirl.create(:survey, :organization_id => organization_id)
          question = FactoryGirl.create(:question, :mandatory => true)
          resp = FactoryGirl.create(:response, :survey => survey, :organization_id => organization_id, :user_id => 1, :status => 'complete')
          resp_attr = { :answers_attributes =>  { '0' => {'content' => nil, 'question_id' => question.id } } }
          put :update, :id => resp.id, :response => resp_attr
          response.should_not be_ok
          response.status.should == 400
        end

        it "updates only the answers which are newer than their corresponding answers in the DB" do
          survey = FactoryGirl.create(:survey, :organization_id => organization_id)
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

        it "chooses whether to update the response status based on `updated_at`" do
          survey = FactoryGirl.create(:survey, :organization_id => organization_id)
          resp = FactoryGirl.create(:response, :organization_id => organization_id, :user_id => 1, :status => 'complete', :survey => survey)
          put :update, :id => resp.id,:survey_id => survey.id, :response => { :status => 'incomplete', :answers_attributes => {}, :updated_at => 5.hours.ago.to_s }
          resp.reload.should be_complete
        end

        it "returns a 410 if the response doesn't exist on the server anymore" do
          put :update, :id => 42, :response => { :status => 'incomplete', :answers_attributes => {}, :updated_at => 5.hours.ago.to_s }
          response.code.should == "410"
        end

        it "returns response with a bad request if survey is expired" do
          survey = FactoryGirl.create(:survey, :organization_id => organization_id)
          survey.update_attribute('expiry_date', Date.yesterday)
          resp = FactoryGirl.create(:response, :survey_id => survey.id, :answers_attributes =>{})
          question_1 = FactoryGirl.create(:question)
          question_2 = FactoryGirl.create(:question)
          resp.answers << FactoryGirl.create(:answer, :question_id => question_1.id)
          resp.answers << FactoryGirl.create(:answer, :question_id => question_2.id)
          resp_attr = { :answers_attributes =>
                        { '0' => {'content' => 'newer', 'question_id' => question_1.id, 'updated_at' => 5.hours.from_now.to_s, 'id' => resp.answers.first.id},
                          '1' => {'content' => 'older', 'question_id' => question_2.id, 'updated_at' => 5.hours.ago.to_s, 'id' => resp.answers.last.id }} }

          put :update, :id => resp.id, :response => resp_attr
          response.should_not be_ok
          response.status.should == 400
        end
      end

      context "POST 'image_upload'" do
        it "saves the photo for an answer" do
          resp = FactoryGirl.create :response, :organization_id => organization_id
          answer = FactoryGirl.create :answer, :response => resp
          request.env['enctype'] = 'multipart/form-data'
          photo = Rack::Test::UploadedFile.new('spec/fixtures/images/sample.jpg')
          photo.content_type = 'image/jpeg'
          post :image_upload, :answer_id => answer.id, :id => answer.response.id, :media => photo
          response.should be_ok
          answer.reload.photo.url.should_not =~ /missing/
        end

        it "returns a :bad_request if an invalid answer ID is passed" do
          request.env['enctype'] = 'multipart/form-data'
          photo = Rack::Test::UploadedFile.new('spec/fixtures/images/sample.jpg')
          photo.content_type = 'image/jpeg'
          post :image_upload, :answer_id => 1231235123, :id => FactoryGirl.create(:response, :organization_id => organization_id).id, :media => photo
          response.should_not be_ok
          response.status.should == 400
        end
      end
    end
  end
end
