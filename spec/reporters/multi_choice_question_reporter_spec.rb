require 'spec_helper'

describe MultiChoiceQuestionReporter do
  let(:question) { MultiChoiceQuestion.find(FactoryGirl.create(:question, :type => "MultiChoiceQuestion").id) }

  context "header" do
    it "includes a header of each of the options as well" do
      reporter = MultiChoiceQuestionReporter.decorate(question)
      option = FactoryGirl.create(:option, :question => question, :content => "Foo")
      reporter.header.size.should == 2
      reporter.header[-1].should == "Foo"
    end
  end

  context "formatted answers" do
    it "returns an array as large as the number of options present plus one" do
      reporter = MultiChoiceQuestionReporter.decorate(question)
      option = FactoryGirl.create_list(:option, 5, :question => question)
      reporter.formatted_answers_for([]).size.should == 6
    end

    it "returns an array whose first element is an empty string" do
      reporter = MultiChoiceQuestionReporter.decorate(question)
      reporter.formatted_answers_for([])[0].should == ""
    end

    it "returns an array with a 'YES' for each option with a corresponding choice" do
      reporter = MultiChoiceQuestionReporter.decorate(question)
      option = FactoryGirl.create(:option, :question => question)
      answer = FactoryGirl.create(:answer)
      choice = FactoryGirl.create(:choice, :answer => answer, :option => option)
      reporter.formatted_answers_for([answer])[-1].should == "YES"
    end

    it "returns an array with a 'NO' for each option without a corresponding choice" do
      reporter = MultiChoiceQuestionReporter.decorate(question)
      option = FactoryGirl.create(:option, :question => question)
      answer = FactoryGirl.create(:answer)
      reporter.formatted_answers_for([answer])[-1].should == "NO"
    end

    it "returns an array of 'NO's (for each option) if no answer is passed in" do
      reporter = MultiChoiceQuestionReporter.decorate(question)
      option = FactoryGirl.create(:option, :question => question)
      reporter.formatted_answers_for([])[-1].should == "NO"
    end
  end
end