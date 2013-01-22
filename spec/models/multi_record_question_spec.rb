require 'spec_helper'

describe MultiRecordQuestion do
  it "is a question with type = 'MultiRecordQuestion'" do
    MultiRecordQuestion.create(:content => "hello")
    question = Question.find_by_content("hello")
    question.should be_a MultiRecordQuestion
    question.type.should == "MultiRecordQuestion"
  end

  it_behaves_like "a question"
end
