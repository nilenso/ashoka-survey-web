require 'spec_helper'

describe DropDownQuestion do
  it { should have_many(:options).dependent(:destroy) }

  it "is a question with type = 'DropDownQuestion'" do
    DropDownQuestion.create(:content => "hello")
    question = Question.find_by_content("hello")
    question.should be_a DropDownQuestion
    question.type.should == "DropDownQuestion"
  end

  it_behaves_like "a question"
end
