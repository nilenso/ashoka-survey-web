require 'spec_helper'

describe SurveyReporter do
  let(:survey) { FactoryGirl.create(:survey) }
  let(:user) { FactoryGirl.build(:user) }

  context "for incomplete responses" do
    it 'returns the number of incomplete responses grouped by the month it was created' do
      response = Timecop.freeze("2013-05-05") { FactoryGirl.create(:response, :incomplete, :user_id => user.id, :survey => survey) }
      response_count = SurveyReporter.new(survey).monthly_incomplete_responses_for(user.id).counts[0]
      response_count.month.should == "May 2013"
      response_count.incompletes.should == 1
    end

    it "doesn't take complete responses into account" do
      complete_responses = FactoryGirl.create_list(:response, 5, :complete, :user_id => user.id, :survey => survey)
      incomplete_response = FactoryGirl.create(:response, :incomplete, :user_id => user.id, :survey => survey)
      response_counts = SurveyReporter.new(survey).monthly_incomplete_responses_for(user.id).counts
      response_counts.length.should == 1
    end

    it "only counts responses for the given user" do
      first_user = FactoryGirl.build(:user)
      second_user = FactoryGirl.build(:user)
      first_users_response = FactoryGirl.create(:response, :incomplete, :user_id => first_user.id, :survey => survey)
      second_users_responses = FactoryGirl.create_list(:response, 5, :incomplete, :user_id => second_user.id, :survey => survey)
      response_counts = SurveyReporter.new(survey).monthly_incomplete_responses_for(first_user.id).counts
      response_counts.length.should == 1
    end

    it "only counts responses for the given survey" do
      first_survey = FactoryGirl.create(:survey)
      second_survey = FactoryGirl.create(:survey)
      first_surveys_response = FactoryGirl.create(:response, :incomplete, :user_id => user.id, :survey => first_survey)
      second_surveys_responses = FactoryGirl.create_list(:response, 5, :incomplete, :user_id => user.id, :survey => second_survey)
      response_counts = SurveyReporter.new(first_survey).monthly_incomplete_responses_for(user.id).counts
      response_counts.length.should == 1
    end
  end

  context "for complete responses" do
    it "returns the number of complete responses per survey per user grouped by the month it was completed" do
      response = Timecop.freeze("2011-05-05") { FactoryGirl.create(:response, :incomplete, :user_id => user.id, :survey => survey) }
      Timecop.freeze("2013-05-05") { response.status = Response::Status::COMPLETE; response.save }
      response_count = SurveyReporter.new(survey).monthly_complete_responses_for(user.id).counts[0]
      response_count.month.should == "May 2013"
      response_count.completes.should == 1
    end

    it "doesn't take incomplete responses into account" do
      user = FactoryGirl.build(:user)
      survey = FactoryGirl.create(:survey)
      complete_response = FactoryGirl.create(:response, :complete, :user_id => user.id, :survey => survey)
      incomplete_response = FactoryGirl.create(:response, :incomplete, :user_id => user.id, :survey => survey)
      response_counts = SurveyReporter.new(survey).monthly_complete_responses_for(user.id).counts
      response_counts.length.should == 1
    end

    it "only counts responses for the given user" do
      first_user = FactoryGirl.build(:user)
      second_user = FactoryGirl.build(:user)
      first_users_response = FactoryGirl.create(:response, :complete, :user_id => first_user.id, :survey => survey)
      second_users_responses = FactoryGirl.create_list(:response, 5, :complete, :user_id => second_user.id, :survey => survey)
      response_counts = SurveyReporter.new(survey).monthly_complete_responses_for(first_user.id).counts
      response_counts.length.should == 1
    end

    it "only counts responses for the given survey" do
      first_survey = FactoryGirl.create(:survey)
      second_survey = FactoryGirl.create(:survey)
      first_surveys_response = FactoryGirl.create(:response, :complete, :user_id => user.id, :survey => first_survey)
      second_surveys_responses = FactoryGirl.create_list(:response, 5, :complete, :user_id => user.id, :survey => second_survey)
      response_counts = SurveyReporter.new(first_survey).monthly_complete_responses_for(user.id).counts
      response_counts.length.should == 1
    end
  end

  context "when combining data for complete and incomplete responses" do
    it "returns a ResponseCounts that combines counts of incomplete and complete repsonses" do
      Timecop.freeze("2013-05-05") { FactoryGirl.create(:response, :complete, :user_id => user.id, :survey => survey) }
      Timecop.freeze("2013-05-05") { FactoryGirl.create_list(:response, 3, :incomplete, :user_id => user.id, :survey => survey) }
      response_counts = SurveyReporter.new(survey).response_counts_for(user.id)
      response_count = response_counts.counts[0]
      response_count.month.should == "May 2013"
      response_count.incompletes.should == 3
      response_count.completes.should == 1
    end

    it "returns an empty ResponseCounts when there are no responses" do
      response_counts = SurveyReporter.new(survey).response_counts_for(user.id)
      response_counts.counts.should be_empty
    end
  end
end
