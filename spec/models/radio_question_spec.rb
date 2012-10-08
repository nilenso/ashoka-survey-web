require 'spec_helper'

describe RadioQuestion do
  it { should have_many(:options).dependent(:destroy) }
  it { should accept_nested_attributes_for(:options) }

  it "is a question with type = 'RadioQuestion'" do
    RadioQuestion.create(:content => "hello")
    question = Question.find_by_content("hello")
    question.should be_a RadioQuestion
    question.type.should == "RadioQuestion"
  end  
end