require 'spec_helper'

describe RatingQuestion do
  it { should respond_to :max_length }
  
  it "is a question with type = 'RatingQuestion'" do
    RatingQuestion.create(:content => "hello")
    question = Question.find_by_content("hello")
    question.should be_a RatingQuestion
    question.type.should == "RatingQuestion"
  end

  it_behaves_like "a question with max length"
end