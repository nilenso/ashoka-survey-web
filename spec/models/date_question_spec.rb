require 'spec_helper'

describe DateQuestion do

  it "is a question with type = 'DateQuestion'" do
    DateQuestion.create!(:content => "hello", :order_number => 11)
    question = Question.find_by_content("hello")
    question.should be_a DateQuestion
    question.type.should == "DateQuestion"
  end

  it_behaves_like "a question"
end