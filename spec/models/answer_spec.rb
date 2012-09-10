require 'spec_helper'

describe Answer do
  it { should respond_to(:content) }
  it { should belong_to(:question) }
  it { should have_many(:choices).dependent(:destroy) }

  context "validations" do
    it "does not save if a mandatory question is not answered" do
      question = FactoryGirl.create(:question, :mandatory => true)
      answer = FactoryGirl.create(:answer, :question_id => question.id)
      question.answers << answer

      answer.content = ''
      answer.should_not be_valid
    end
    it "does not save if content of the answer exceeds maximum length" do
      question = FactoryGirl.create(:question, :max_length => 7)
      answer = FactoryGirl.create(:answer, :question_id => question.id)
      question.answers << answer

      answer.content = 'foobarbaz'
      answer.should_not be_valid
    end

    it "does not save if the answer is not within the range of a numeric question" do
      question = FactoryGirl.create(:question, :type => 'NumericQuestion', :min_value => 5, :max_value => 7)
      answer = FactoryGirl.build(:answer, :question_id => question.id)
      question.answers << answer

      answer.content = 3
      answer.should_not be_valid
    end
  end

  context "when creating choices for a MultiChoiceQuestion" do
    it "creates choices from the answer's content" do
      choices = ["First", "Second"]
      question = FactoryGirl.create(:question, :type => 'MultiChoiceQuestion')
      answer = FactoryGirl.create(:answer, :question_id => question.id, :content => choices)
      answer.choices.map(&:content).should =~ choices
    end

    it "doesn't create choices for any other question type" do
      question = FactoryGirl.create(:question, :type => 'SingleLineQuestion')
      answer = FactoryGirl.create(:answer, :question_id => question.id)
      answer.choices.should == []
    end

    it "it sets the answer content to 'MultipleChoice'" do
      choices = ["first"]
      question = FactoryGirl.create(:question, :type => 'MultiChoiceQuestion')
      answer = FactoryGirl.create(:answer, :question_id => question.id, :content => choices)
      answer.content.should == "MultipleChoice"
    end

  end
end
