require 'spec_helper'

describe ResponseSerializer do
  context "#to_json_with_answers_and_choices" do
    it "renders the answers" do
      response = (FactoryGirl.create :response_with_answers).reload
      response_serializer = ResponseSerializer.new(response)
      response_json = JSON.parse(response_serializer.to_json_with_answers_and_choices)
      response_json.should have_key('answers')
      response_json['answers'].size.should == response.answers.size
    end

    it "renders the answers' image as base64 as well" do
      ImageUploader.storage = :file
      response = (FactoryGirl.create :response).reload
      photo = Rack::Test::UploadedFile.new('spec/fixtures/images/sample.jpg')
      photo.content_type = 'image/jpeg'
      photo_answer = FactoryGirl.create(:answer, :photo => photo, :question => FactoryGirl.create(:question, :type => 'PhotoQuestion'))
      response.answers << photo_answer
      response_serializer = ResponseSerializer.new(response)
      response_json = JSON.parse(response_serializer.to_json_with_answers_and_choices)
      response_json['answers'][0].should have_key('photo_in_base64')
      response_json['answers'][0]['photo_in_base64'].should == photo_answer.photo_in_base64
    end

    it "renders the answers' choices if any" do
      response = (FactoryGirl.create :response).reload
      response.answers << FactoryGirl.create(:answer_with_choices)
      response_serializer = ResponseSerializer.new(response)
      response_json = JSON.parse(response_serializer.to_json_with_answers_and_choices)
      response_json['answers'][0].should have_key('choices')
      response_json['answers'][0]['choices'].size.should == response.answers[0].choices.size
    end
  end

  context "#render_json" do
    context "response is invalid" do
      it "returns the json with answers and doesn't delete the response" do
        (FactoryGirl.create :response_with_answers).reload
        response = Response.new
        response_serializer = ResponseSerializer.new(response)
        response_serializer.render_json.should == response_serializer.to_json_with_answers_and_choices
        response.should_not be_frozen
      end
    end
    context "response is valid" do
      it "it marks response complete and returns json with answers" do
        response = FactoryGirl.create(:response, :status => "validating")
        response_serializer = ResponseSerializer.new(response)
        response_serializer.render_json.should == response_serializer.to_json_with_answers_and_choices
        response.should be_complete
      end

      it "returns the json if response is incomplete" do
        response = FactoryGirl.create(:response, :status => "incomplete")
        response_serializer = ResponseSerializer.new(response)
        response_serializer.render_json.should == response_serializer.to_json_with_answers_and_choices
        response.should be_incomplete
      end
    end
  end
end
