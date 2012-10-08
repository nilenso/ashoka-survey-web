require 'spec_helper'

describe MultilineQuestion do
  it { should respond_to :max_length }

  it "is a question with type = 'MultilineQuestion'" do
    MultilineQuestion.create(:content => "hello", :order_number => 11)
    question = Question.find_by_content("hello")
    question.should be_a MultilineQuestion
    question.type.should == "MultilineQuestion"
  end

  it_behaves_like "a question"

  it_behaves_like "a question with max length"
end
