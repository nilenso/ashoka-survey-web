require "spec_helper"

describe Reports::Excel::Questions do
  let!(:survey) { FactoryGirl.create(:survey) }
  let!(:question) { FactoryGirl.create(:question, :survey => survey) }
  let!(:private_question) { FactoryGirl.create(:question, :survey => survey, :private => true) }

  it "includes all the questions of the survey" do
    questions = Reports::Excel::Questions.new(survey)
    questions.all.should == [question, private_question]
  end

  context "when filtering out private questions" do
    it "performs the filtering if options[:filter_private_questions] is true" do
      questions = Reports::Excel::Questions.new(survey)
      questions.build(:filter_private_questions => true).all.should == [question]
    end

    it "doesn't performs the filtering if options[:filter_private_questions] is falsy" do
      questions = Reports::Excel::Questions.new(survey)
      questions.build.all.should == [question, private_question]
    end
  end
end
