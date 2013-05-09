require 'spec_helper'

describe SingleLineQuestion do
  it "is a question with type = 'SingleLineQuestion'" do
    question = FactoryGirl.create(:single_line_question)
    question.should be_a SingleLineQuestion
    question.type.should == "SingleLineQuestion"
  end

  it_behaves_like "a question with max length"

  it_behaves_like "a question"
end
