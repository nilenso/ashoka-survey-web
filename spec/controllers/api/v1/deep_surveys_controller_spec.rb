require 'spec_helper'

describe Api::V1::DeepSurveysController do
  context "GET index" do
    before(:each) { sign_in_as('viewer') }

    it "fetches active surveys"do
      finalized_survey = FactoryGirl.create(:survey, :finalized, :organization_id => LOGGED_IN_ORG_ID)
      unfinalized_survey = FactoryGirl.create(:survey, :organization_id => LOGGED_IN_ORG_ID)
      get :index
      response_hash = JSON.parse(response.body)
      response_hash.map { |s| s['id'] }.should == [finalized_survey.id]
    end

    it "fetches extra surveys passed in the params" do
      expired_survey = FactoryGirl.create(:survey, :expiry_date => 5.days.from_now, :organization_id => LOGGED_IN_ORG_ID)
      Timecop.freeze(7.days.from_now) do
        finalized_survey = FactoryGirl.create(:survey, :finalized, :organization_id => LOGGED_IN_ORG_ID)
        get :index, :extra_surveys => "#{expired_survey.id}"
        response_hash = JSON.parse(response.body)
        response_hash.map { |s| s['id'] }.should =~ [finalized_survey.id, expired_survey.id]
      end
    end

    it "does not include unauthorized surveys" do
      other_organization_id = 500
      unauthorized_survey = FactoryGirl.create(:survey, :finalized, :organization_id => other_organization_id)
      authorized_survey = FactoryGirl.create(:survey, :finalized, :organization_id => LOGGED_IN_ORG_ID)
      get :index
      response_hash = JSON.parse(response.body)
      response_hash.map { |s| s['id'] }.should =~ [authorized_survey.id]
    end

    it "does not include unauthorized surveys even if explicitly specified in the params" do
      other_organization_id = 500
      unauthorized_survey = FactoryGirl.create(:survey, :finalized, :organization_id => other_organization_id)
      authorized_survey = FactoryGirl.create(:survey, :finalized, :organization_id => LOGGED_IN_ORG_ID)
      get :index, :extra_surveys => "#{unauthorized_survey.id}"
      response_hash = JSON.parse(response.body)
      response_hash.map { |s| s['id'] }.should =~ [authorized_survey.id]
    end

    context "for nested elements" do
      it "should list questions along with the surveys" do
        file = fixture_file_upload('/images/sample.jpg')
        Question.any_instance.stub_chain(:image, :thumb, :file).and_return(file)
        survey = FactoryGirl.create(:survey, :organization_id => LOGGED_IN_ORG_ID)
        question_list = FactoryGirl.create_list(:radio_question, 5, :with_options, :finalized, :survey => survey)
        survey.finalize
        get :index
        response_hash = JSON.parse(response.body)
        survey_json = response_hash[0]
        survey_json['questions'].map { |q| q['id']}.should =~ question_list.map(&:id)
      end

      it "should list categories along with the surveys" do
        survey = FactoryGirl.create(:survey, :organization_id => LOGGED_IN_ORG_ID)
        category_list = FactoryGirl.create_list(:category, 5, :finalized, :survey => survey)
        survey.finalize
        get :index
        response_hash = JSON.parse(response.body)
        survey_json = response_hash[0]
        survey_json['categories'].map { |q| q['id']}.should =~ category_list.map(&:id)
      end
    end
  end
end
