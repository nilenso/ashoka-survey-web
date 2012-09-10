require 'spec_helper'

describe Answer do
  it { should respond_to(:content) }
  it { should belong_to(:question) }
  it { should have_many(:choices).dependent(:destroy) }
  it { should accept_nested_attributes_for(:choices) }
  
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
end
