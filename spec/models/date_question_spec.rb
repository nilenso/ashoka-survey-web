require 'spec_helper'

describe DateQuestion do
  it { should respond_to :content }
  it { should respond_to :mandatory }
  it { should respond_to :image }
  it { should belong_to :survey }
  it { should have_many(:answers).dependent(:destroy) }
  it { should validate_presence_of :content }
  
  it "is a question with type = 'DateQuestion'" do
    DateQuestion.create!(:content => "hello", :order_number => 11)
    question = Question.find_by_content("hello")
    question.should be_a DateQuestion
    question.type.should == "DateQuestion"
  end
end