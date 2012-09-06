require 'spec_helper'

describe MultilineQuestion do
  it { should respond_to :content }
  it { should respond_to :mandatory }
  it { should respond_to :image }
  it { should respond_to :max_length }
  it { should belong_to :survey }
  it { should have_many(:answers).dependent(:destroy) }
  it { should validate_presence_of :content }
  
  it "is a question with type = 'MultilineQuestion'" do
    MultilineQuestion.create(:content => "hello")
    question = Question.find_by_content("hello")
    question.should be_a MultilineQuestion
    question.type.should == "MultilineQuestion"
  end
end