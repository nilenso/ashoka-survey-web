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
          returned_json = JSON.parse(response.body)
          returned_json.keys.map(&:to_sym).should == expected_json.keys
          returned_json['content'].should == expected_json[:content]
        end
      end
      context "PUT 'update'" do
        it "updates the question" do
          question = FactoryGirl.create(:question)
          put :update, :id => question.id, :content => "hello"
          question.reload
          Question.find(question.id).should == question
        end
        it "redirects to the root path with a flash message when save is successful" do
          question = FactoryGirl.create(:question)
          put :update, :id => question.id, :content => "hello"
          response.should redirect_to(root_path)
          flash[:notice].should_not be_nil
        end
        it "renders the question with a flash error when save is unsuccessful" do
          question = FactoryGirl.create(:question)
          put :update, :id => question.id
          flash[:error].should_not be_nil
        end
      end
    end
  end
end
