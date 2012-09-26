require 'spec_helper'

module Api
  module V1
    describe SurveysController do
      context "GET 'index'" do
        it "responds with JSON" do
          surveys = FactoryGirl.create(:survey)
          get :index
          response.should be_ok
          lambda { JSON.parse(response.body) }.should_not raise_error
        end

        it "responds with the id, name, expiry date and the description of the survey" do
          FactoryGirl.create(:survey)
          get :index
          returned_json = JSON.parse(response.body).first
          returned_json.keys.should =~ ['id', 'name', 'description', 'expiry_date']
        end

        it "responds with details for all the surveys stored" do
          surveys = FactoryGirl.create_list(:survey, 15)
          get :index
          returned_json = JSON.parse(response.body)
          returned_json.length.should == 15
          surveys.each_with_index do |survey, index|
            returned_json[index]['name'].should == survey.name
            returned_json[index]['description'].should == survey.description
            Date.parse(returned_json[index]['expiry_date']).should == survey.expiry_date
          end
        end
      end

      context "GET 'show" do
        it "responds with all the questions in a survey" do
          survey = FactoryGirl.create(:survey_with_questions)
          get :show, :id => survey.id
          returned_json = JSON.parse(response.body)
          returned_json.length.should == 5
          survey.questions.each_with_index do |question, index|
            returned_json[index]['id'].should == question.id
            returned_json[index]['content'].should == question.content
          end
        end
      end
    end
  end
end
