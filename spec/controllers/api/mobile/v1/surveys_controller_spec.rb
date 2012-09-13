require 'spec_helper'

module Api
  module Mobile
    module V1
      describe SurveysController do
        context "GET 'index'" do
          it "responds with JSON" do
            surveys = FactoryGirl.create(:survey)
            get :index
            response.should be_ok
            lambda { JSON.parse(response.body) }.should_not raise_error
          end

          it "responds with the survey names" do
            surveys = FactoryGirl.create_list(:survey, 5)
            get :index
            returned_json = JSON.parse(response.body)
            surveys.map(&:name).each do |survey_name|
              returned_json.should include survey_name
            end
          end
        end
      end
    end
  end
end
