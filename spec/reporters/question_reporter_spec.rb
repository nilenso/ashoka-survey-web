require 'spec_helper'

describe QuestionReporter do
  context "formatted answers" do
    it "returns an empty string if no answers are passed in" do
      reporter = QuestionReporter.decorate(FactoryGirl.create(:question))
      reporter.formatted_answers_for([]).should == ""
    end

    it "returns the answer's content if a single one is passed in" do
      reporter = QuestionReporter.decorate(FactoryGirl.create(:question, :finalized))
      answer = FactoryGirl.create(:answer, :question_id => reporter.id, :content => "ABC")
      reporter.formatted_answers_for([answer]).should == "ABC"
    end

    it "returns a comma-separated list of answers' contents if more than one is passed in" do
      reporter = QuestionReporter.decorate(FactoryGirl.create(:question, :finalized))
      first_answer = FactoryGirl.create(:answer, :question_id => reporter.id, :content => "ABC")
      second_answer = FactoryGirl.create(:answer, :question_id => reporter.id, :content => "XYZ")
      reporter.formatted_answers_for([first_answer, second_answer]).should == "ABC, XYZ"
    end
  end
end
