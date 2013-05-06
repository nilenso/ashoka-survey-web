require "spec_helper"

describe Reports::Excel::Questions do
  let!(:survey) { FactoryGirl.create(:survey) }
  let!(:question) { FactoryGirl.create(:question, :survey => survey) }
  let!(:private_question) { FactoryGirl.create(:question, :survey => survey, :private => true) }
  let(:admin_ability) { stub }
  let(:user_ability) { stub }

  before(:each) do
    admin_ability.stub(:authorize!).and_return(true)
    user_ability.stub(:authorize!).and_raise(CanCan::AccessDenied)
  end

  it "includes all the questions of the survey" do
    questions = Reports::Excel::Questions.new(survey, admin_ability)
    questions.all.should == [question, private_question]
  end

  context "when filtering out private questions" do
    it "performs the filtering by default" do
      questions = Reports::Excel::Questions.new(survey, admin_ability)
      questions.build.all.should == [question]
    end

    it "doesn't perform the filtering if options[:disable_filtering] is true" do
      questions = Reports::Excel::Questions.new(survey, admin_ability)
      questions.build(:disable_filtering => true).all.should == [question, private_question]
    end

    it "raises an exception if options[:disable_filtering] is true and the current user doesn't have permission to change filters for the given survey" do
      questions = Reports::Excel::Questions.new(survey, user_ability)
      expect { questions.build(:disable_filtering => true).all }.to raise_error
    end
  end
end
