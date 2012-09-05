require 'spec_helper'

module Api
  module V1
    describe QuestionsController do
      context "POST 'create'" do
        it "creates a new question" do
          survey = FactoryGirl.create(:survey)
          question = FactoryGirl.attributes_for(:question)

          expect do
            post :create, :survey_id => survey.id, :question => question
          end.to change { Question.count }.by(1)
        end

        it "creates a new question based on the type" do
          survey = FactoryGirl.create(:survey)
          question = FactoryGirl.attributes_for(:question)
          question['type'] = 'RadioQuestion'
          expect do
            post :create, :survey_id => survey.id, :question => question
          end.to change { RadioQuestion.count }.by(1)
        end

        it "returns the created question as JSON" do
          expected_json = { content: "MyText",
                            created_at: "2012-08-28T08: 22: 50Z",
                            id: 797,
                            image_content_type: nil,
                            image_file_name: nil,
                            image_file_size: nil,
                            image_updated_at: nil,
                            mandatory: false,
                            max_length: nil,
                            survey_id: 811,
                            updated_at: "2012-08-28T08: 22: 50Z"
                            }
          survey = FactoryGirl.create(:survey)
          question = FactoryGirl.attributes_for(:question)
          question['type'] = 'RadioQuestion'
          post :create, :survey_id => survey.id, :question => question
          response.should be_ok
          returned_json = JSON.parse(response.body)
          returned_json.keys.map(&:to_sym).should == expected_json.keys
          returned_json['content'].should == expected_json[:content]
        end

        context "when save is unsuccessful" do
          it "returns the errors with a bad_request status" do
            survey = FactoryGirl.create(:survey)
            question = FactoryGirl.attributes_for(:question)
            question[:content] = ''
            post :create, :survey_id => survey.id, :question => question

            response.status.should == 400
            JSON.parse(response.body).should be_any {|m| m =~ /can\'t be blank/ }
          end
        end
      end

      context "PUT 'update'" do
        it "updates the question" do
          question = FactoryGirl.create(:question)
          put :update, :id => question.id, :question => {:content => "hello"}
          Question.find(question.id).content.should == "hello"
        end

        it "returns the updated question as JSON" do
          question = FactoryGirl.create(:question)
          put :update, :id => question.id, :question => {:content => "someuniquestring"}
          JSON.parse(response.body)["content"].should == "someuniquestring"
        end

        context "when update is unsuccessful" do
          it "returns the errors with a bad request status" do
            question = FactoryGirl.create(:question)
            put :update, :id => question.id, :question => {:content => ""}
            response.status.should == 400
            JSON.parse(response.body).should be_any {|m| m =~ /can\'t be blank/ }
          end
        end
      end

      context "POST image_upload" do
        it "uploads the image for given question" do
          question = FactoryGirl.create(:question)
          @file = fixture_file_upload('/images/sample.jpg', 'text/xml')
          post :image_upload, :id => question.id, :image => @file
          response.should be_ok
          question.reload.image.should be
          question.reload.image.should_not eq '/images/original/missing.png'
        end
      end
    end
  end
end
