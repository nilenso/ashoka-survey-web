require "spec_helper"

describe Reports::Excel::Questions do
  let!(:survey) { FactoryGirl.create(:survey) }
  let!(:finalized_question) { FactoryGirl.create(:question, :finalized, :survey => survey) }
  let!(:private_question) { FactoryGirl.create(:question, :finalized, :private, :survey => survey) }
  let(:admin_ability) { stub }
  let(:user_ability) { stub }

  before(:each) do
    admin_ability.stub(:authorize!).and_return(true)
    user_ability.stub(:authorize!).and_raise(CanCan::AccessDenied)
  end

  it "includes only the finalized questions of the survey" do
    unfinalized_question = FactoryGirl.create(:question, :finalized => false, :survey => survey)
    questions = Reports::Excel::Questions.new(survey, admin_ability)
    questions.all.should == [finalized_question, private_question]
  end

  it "includes the sub-questions adjacent to their parent question" do
    survey = FactoryGirl.create(:survey)
    first_question = FactoryGirl.create(:radio_question, :finalized, :survey => survey, :order_number => 1)
    sub_question = FactoryGirl.create(:question, :finalized, :survey => survey, :parent => FactoryGirl.create(:option, :question => first_question))
    second_question = FactoryGirl.create(:question, :finalized, :survey => survey, :order_number => 2)
    questions = Reports::Excel::Questions.new(survey, admin_ability).build
    questions.all.should == [first_question, sub_question, second_question]
  end

  context "when filtering out private questions" do
    it "performs the filtering by default" do
      questions = Reports::Excel::Questions.new(survey, admin_ability)
      questions.build.all.should == [finalized_question]
    end

    it "doesn't perform the filtering if options[:disable_filtering] is true" do
      questions = Reports::Excel::Questions.new(survey, admin_ability)
      questions.build(:disable_filtering => true).all.should == [finalized_question, private_question]
    end

    it "raises an exception if options[:disable_filtering] is true and the current user doesn't have permission to change filters for the given survey" do
      questions = Reports::Excel::Questions.new(survey, user_ability)
      expect { questions.build(:disable_filtering => true).all }.to raise_error
    end
  end
end
