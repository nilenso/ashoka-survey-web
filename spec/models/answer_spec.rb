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

    it "does not save if the answer is less than the minimum value" do
      question = FactoryGirl.create(:question, :type => 'NumericQuestion', :min_value => 5)
      answer = FactoryGirl.build(:answer, :question_id => question.id)
      question.answers << answer

      answer.content = 3
      answer.should_not be_valid
    end

    context "when validating numeric questions"
    it "does not save if the answer is greater than the maximum value" do
      question = FactoryGirl.create(:question, :type => 'NumericQuestion', :max_value => 5)
      answer = FactoryGirl.build(:answer, :question_id => question.id)
      question.answers << answer

      answer.content = 8
      answer.should_not be_valid
    end

    it "does not save if the answer to a date type question is not a valid date" do
      question = FactoryGirl.create(:question, :type => 'DateQuestion')
      answer = FactoryGirl.build(:answer, :question_id => question.id)
      question.answers << answer

      answer.content = "4235643861"
      answer.should_not be_valid
      answer.content = "1990/10/24"
      answer.should be_valid
    end
  end

  context "for multi-choice questions" do
    it "does not save if it doesn't have any choices selected" do
      question = FactoryGirl.create(:question, :type => 'MultiChoiceQuestion', :mandatory => true)
      answer = FactoryGirl.build(:answer, :question_id => question.id, :content => [""])
      answer.should_not be_valid
    end

    it "saves if even a single choice is selected" do
      question = FactoryGirl.create(:question, :type => 'MultiChoiceQuestion', :mandatory => true)
      answer = FactoryGirl.build(:answer, :question_id => question.id, :content => ["first"])
      answer.should be_valid
    end
  end

  context "when creating choices for a MultiChoiceQuestion" do
    it "creates choices for the selected options" do
      options = FactoryGirl.create_list(:option, 3)
      question = FactoryGirl.create(:question, :type => 'MultiChoiceQuestion', :options => options)
      answer = FactoryGirl.create(:answer, :question_id => question.id, :content => options.map(&:id))
      answer.choices.map(&:option_id).should =~ options.map(&:id)
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
