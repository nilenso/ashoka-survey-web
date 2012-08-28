require 'spec_helper'

describe QuestionsController do
  context "POST 'create'" do
    it "creates a new question" do
      survey = FactoryGirl.create(:survey)
      expect do
        post :create, :survey_id => survey.id
      end.to change { Question.count }.by(1)
    end

    it "creates a new question based on the type" do
      survey = FactoryGirl.create(:survey)
      expect do
        post :create, :survey_id => survey.id, :type => "RadioQuestion"
      end.to change { RadioQuestion.count }.by(1)
    end

    it "returns the created question as JSON" do
      expected_json = { content: "untitled question",
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
      post :create, :survey_id => survey.id, :type => "RadioQuestion"
      returned_json = JSON.parse(response.body)
      returned_json.keys.map(&:to_sym).should == expected_json.keys
      returned_json['content'].should == expected_json[:content]
    end
  end
end