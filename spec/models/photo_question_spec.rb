require 'spec_helper'

describe PhotoQuestion do
  it { should respond_to :max_length }

  it "is a question with type = 'PhotoQuestion'" do
    PhotoQuestion.create(:content => "hello")
    question = Question.find_by_content("hello")
    question.should be_a PhotoQuestion
    question.type.should == "PhotoQuestion"
  end
end