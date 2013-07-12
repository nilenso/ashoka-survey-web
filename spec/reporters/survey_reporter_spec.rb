require 'spec_helper'

describe SurveyReporter do
  let(:survey) { FactoryGirl.create(:survey) }
  let(:user) { FactoryGirl.build(:user) }

  context "for incomplete responses" do
    it 'returns the number of incomplete responses grouped by the month it was created' do
      response_1 = Timecop.freeze("2013-05-05") { FactoryGirl.create(:response, :incomplete, :user_id => user.id, :survey => survey) }
      response_2 = Timecop.freeze("2013-06-06") { FactoryGirl.create(:response, :incomplete, :user_id => user.id, :survey => survey) }
      report = SurveyReporter.new(survey).monthly_incomplete_responses_for(user.id)
      report.should == {"May 2013" => 1, "Jun 2013" => 1}
    end

    it "doesn't take complete responses into account" do
      complete_responses = FactoryGirl.create_list(:response, 5, :complete, :user_id => user.id, :survey => survey)
      incomplete_response = FactoryGirl.create(:response, :incomplete, :user_id => user.id, :survey => survey)
      report = SurveyReporter.new(survey).monthly_incomplete_responses_for(user.id)
      report.values.reduce(:+).should == 1
    end

    it "only counts responses for the given user" do
      first_user = FactoryGirl.build(:user)
      second_user = FactoryGirl.build(:user)
      first_users_response = FactoryGirl.create(:response, :incomplete, :user_id => first_user.id, :survey => survey)
      second_users_responses = FactoryGirl.create_list(:response, 5, :incomplete, :user_id => second_user.id, :survey => survey)
      report = SurveyReporter.new(survey).monthly_incomplete_responses_for(first_user.id)
      report.values.reduce(:+).should == 1
    end

    it "only counts responses for the given survey" do
      first_survey = FactoryGirl.create(:survey)
      second_survey = FactoryGirl.create(:survey)
      first_surveys_response = FactoryGirl.create(:response, :incomplete, :user_id => user.id, :survey => first_survey)
      second_surveys_responses = FactoryGirl.create_list(:response, 5, :incomplete, :user_id => user.id, :survey => second_survey)
      report = SurveyReporter.new(first_survey).monthly_incomplete_responses_for(user.id)
      report.values.reduce(:+).should == 1
    end
  end

  context "for complete responses" do
    it "returns the number of complete responses per survey per user grouped by the month it was completed" do
      user = FactoryGirl.build(:user)
      survey = FactoryGirl.create(:survey)
      response_1 = Timecop.freeze("2011-05-05") { FactoryGirl.create(:response, :incomplete, :user_id => user.id, :survey => survey) }
      response_2 = Timecop.freeze("2011-05-05") { FactoryGirl.create(:response, :incomplete, :user_id => user.id, :survey => survey) }
      Timecop.freeze("2013-05-05") { response_1.status = Response::Status::COMPLETE; response_1.save }
      Timecop.freeze("2013-06-06") { response_2.status = Response::Status::COMPLETE; response_2.save }
      report = SurveyReporter.new(survey).monthly_complete_responses_for(user.id)
      report.should == {"May 2013" => 1, "Jun 2013" => 1}
    end

    it "doesn't take incomplete responses into account" do
      user = FactoryGirl.build(:user)
      survey = FactoryGirl.create(:survey)
      complete_response = FactoryGirl.create(:response, :complete, :user_id => user.id, :survey => survey)
      incomplete_response = FactoryGirl.create(:response, :incomplete, :user_id => user.id, :survey => survey)
      report = SurveyReporter.new(survey).monthly_complete_responses_for(user.id)
      report.values.reduce(:+).should == 1
    end

    it "only counts responses for the given user" do
      first_user = FactoryGirl.build(:user)
      second_user = FactoryGirl.build(:user)
      first_users_response = FactoryGirl.create(:response, :complete, :user_id => first_user.id, :survey => survey)
      second_users_responses = FactoryGirl.create_list(:response, 5, :complete, :user_id => second_user.id, :survey => survey)
      report = SurveyReporter.new(survey).monthly_complete_responses_for(first_user.id)
      report.values.reduce(:+).should == 1
    end

    it "only counts responses for the given survey" do
      first_survey = FactoryGirl.create(:survey)
      second_survey = FactoryGirl.create(:survey)
      first_surveys_response = FactoryGirl.create(:response, :complete, :user_id => user.id, :survey => first_survey)
      second_surveys_responses = FactoryGirl.create_list(:response, 5, :complete, :user_id => user.id, :survey => second_survey)
      report = SurveyReporter.new(first_survey).monthly_complete_responses_for(user.id)
      report.values.reduce(:+).should == 1
    end
  end

  context "when combining data for complete and incomplete responses" do
    it "returns a hash of dates mapped to a hash containing incomplete and complete response counts" do
      Timecop.freeze("2013-05-05") { FactoryGirl.create(:response, :complete, :user_id => user.id, :survey => survey) }
      Timecop.freeze("2013-05-05") { FactoryGirl.create_list(:response, 3, :incomplete, :user_id => user.id, :survey => survey) }
      report = SurveyReporter.new(survey).response_counts_for(user.id)
      report.should == { "May 2013" => { Response::Status::INCOMPLETE => 3, Response::Status::COMPLETE => 1 }}
    end

    it "returns a zero count when there are no responses" do
      Timecop.freeze("2013-05-05") { FactoryGirl.create(:response, :complete, :user_id => user.id, :survey => survey) }
      report = SurveyReporter.new(survey).response_counts_for(user.id)
      report.should == { "May 2013" => { Response::Status::INCOMPLETE => 0, Response::Status::COMPLETE => 1 }}
    end
  end
end
