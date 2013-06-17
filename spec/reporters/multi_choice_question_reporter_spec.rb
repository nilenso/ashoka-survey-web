require 'spec_helper'

describe MultiChoiceQuestionReporter do
  let(:question) { FactoryGirl.create(:multi_choice_question, :finalized) }

  context "header" do
    it "includes a header of each of the options as well" do
      reporter = MultiChoiceQuestionReporter.decorate(question)
      option = FactoryGirl.create(:option, :question => question, :content => "Foo")
      reporter.header.size.should == 2
      reporter.header[-1].should == "Foo"
    end

    it "includes the options in ascending order" do
      reporter = MultiChoiceQuestionReporter.decorate(question)
      FactoryGirl.create(:option, :question => question, :content => "Foo", :order_number => 1)
      FactoryGirl.create(:option, :question => question, :content => "Bar", :order_number => 2)
      reporter.header.last(2).should == ["Foo", "Bar"]
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

    context "for multi-records" do
      it "returns a comma separated list of YES/NOs for each option; one for each answer passed in" do
        reporter = MultiChoiceQuestionReporter.decorate(question)
        option = FactoryGirl.create(:option, :question => question)
        answers = FactoryGirl.create_list(:answer, 2, :question => question)
        choice = FactoryGirl.create(:choice, :answer => answers[0], :option => option)
        reporter.formatted_answers_for(answers)[-1].should == "YES, NO"
      end
    end
  end
end
