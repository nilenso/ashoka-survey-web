require 'spec_helper'

describe NumericQuestion do
  it { should respond_to :max_value }
  it { should respond_to :min_value }
  
  it "is a question with type = 'NumericQuestion'" do
    NumericQuestion.create(:content => "hello",:order_number => 11)
    question = Question.find_by_content("hello")
    question.should be_a NumericQuestion
    question.type.should == "NumericQuestion"
  end

  it "should not allow a min-value greater than max-value" do
    numeric_question = NumericQuestion.new(:content => "foo", :min_value => 5, :max_value => 2)
    numeric_question.should_not be_valid
  end

  it "should allow a min-value equal to the max-value" do
    numeric_question = NumericQuestion.new(:content => "foo", :min_value => 5, :max_value => 5)
    numeric_question.should be_valid
  end

  it_behaves_like "a question"
end
