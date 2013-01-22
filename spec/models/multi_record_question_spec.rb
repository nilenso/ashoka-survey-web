require 'spec_helper'

describe MultiRecordQuestion do
  it "is a question with type = 'MultiRecordQuestion'" do
    MultiRecordQuestion.create(:content => "hello")
    question = Question.find_by_content("hello")
    question.should be_a MultiRecordQuestion
    question.type.should == "MultiRecordQuestion"
  end

  it_behaves_like "a question"

  it { should have_many :questions }

  context "as_json" do
    it "includes it's questions in the json" do
      mrq = MultiRecordQuestion.create(:content => "foo")
      foo = FactoryGirl.create(:question)
      mrq.questions << foo
      mrq.as_json[:questions].should == [foo.as_json(:methods => :type)]
    end
  end
end
