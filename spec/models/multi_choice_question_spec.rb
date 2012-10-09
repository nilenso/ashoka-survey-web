require 'spec_helper'

describe MultiChoiceQuestion do
  it { should have_many(:options).dependent(:destroy) }

  it "is a question with type = 'MultiChoiceQuestion'" do
    MultiChoiceQuestion.create(:content => "hello")
    question = Question.find_by_content("hello")
    question.should be_a MultiChoiceQuestion
    question.type.should == "MultiChoiceQuestion"
  end

  it_behaves_like "a question"
end
