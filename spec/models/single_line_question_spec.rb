require 'spec_helper'

describe SingleLineQuestion do
  it { should respond_to :max_length }
  
  it "is a question with type = 'SingleLineQuestion'" do
    SingleLineQuestion.create(:content => "hello")
    question = Question.find_by_content("hello")
    question.should be_a SingleLineQuestion
    question.type.should == "SingleLineQuestion"
  end
end