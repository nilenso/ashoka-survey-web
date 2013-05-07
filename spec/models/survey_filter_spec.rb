require 'spec_helper'

describe SurveyFilter do
  context "filters surveys" do
    it "returns drafts surveys if survey filter is set to 'drafts'" do
      survey = FactoryGirl.create(:survey, :finalized => false)
      another_survey = FactoryGirl.create(:survey, :finalized => true)
      filter_surveys = SurveyFilter.new(Survey.limit(2), "drafts")
      filter_surveys.filter.should include(survey)
      filter_surveys.filter.should_not include(another_survey)
    end

    it "returns archived surveys if survey filter is set to 'archived'" do
      archived_survey = FactoryGirl.create(:survey, :archived)
      another_survey = FactoryGirl.create(:survey, :archived => false)
      filter_surveys = SurveyFilter.new(Survey.limit(2), "archived")
      filter_surveys.filter.should include(archived_survey)
      filter_surveys.filter.should_not include(another_survey)
    end

    context "when survey filter is set to 'expired'" do
      it "returns expired surveys" do
        survey = FactoryGirl.create(:survey)
        survey.update_attribute(:expiry_date, 2.days.ago)
        another_survey = FactoryGirl.create(:survey, :finalized => true)
        filter_surveys = SurveyFilter.new(Survey.limit(2), "expired")
        filter_surveys.filter.should include(survey)
        filter_surveys.filter.should_not include(another_survey)
      end

      it "does not include archived surveys" do
        expired_archived_survey = Timecop.freeze(1.week.ago) { FactoryGirl.create(:survey, :archived, :expiry_date => 3.days.from_now) }
        expired_survey = Timecop.freeze(1.week.ago) { FactoryGirl.create(:survey, :expiry_date => 3.days.from_now) }
        filter_surveys = SurveyFilter.new(Survey.limit(2), "expired")
        filter_surveys.filter.should == [expired_survey]
      end
    end

    it "returns active surveys if no survey filter is specified" do
      survey = FactoryGirl.create(:survey, :finalized => true)
      another_survey = FactoryGirl.create(:survey, :finalized => false)
      filter_surveys = SurveyFilter.new(Survey.limit(2), nil)
      filter_surveys.filter.should include(survey)
      filter_surveys.filter.should_not include(another_survey)
    end
  end
end
