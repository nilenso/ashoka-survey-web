require 'spec_helper'

describe NumericQuestion do
  it { should respond_to :content }
  it { should respond_to :mandatory }
  it { should respond_to :image }
  it { should respond_to :max_value }
  it { should respond_to :min_value }
  it { should belong_to :survey }
  it { should have_many(:answers).dependent(:destroy) }
  it { should validate_presence_of :content }
  
  it "is a question with type = 'NumericQuestion'" do
    NumericQuestion.create(:content => "hello")
    question = Question.find_by_content("hello")
    question.should be_a NumericQuestion
    question.type.should == "NumericQuestion"
  end
end