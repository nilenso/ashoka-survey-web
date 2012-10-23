require 'spec_helper'

describe RadioQuestion do
  it { should have_many(:options).dependent(:destroy) }

  it "is a question with type = 'RadioQuestion'" do
    RadioQuestion.create(:content => "hello", :order_number => 12345)
    question = Question.find_by_content("hello")
    question.should be_a RadioQuestion
    question.type.should == "RadioQuestion"
  end

  it_behaves_like "a question"

  context "reports" do
    it "counts all its answers grouped by the option's content " do
      question = RadioQuestion.find(FactoryGirl.create(:question_with_options).id)
      5.times { question.answers << FactoryGirl.create(:answer_with_complete_response, :content => question.options.first.content) }
      3.times { question.answers << FactoryGirl.create(:answer_with_complete_response, :content => question.options.last.content) }
      question.report_data.should include [question.options.first.content, 5]
      question.report_data.should include [question.options.last.content, 3]
    end

    it "returns an empty array if no answers exist for the question" do
      question = RadioQuestion.find(FactoryGirl.create(:question_with_options).id)
      question.report_data.should be_empty
    end
  end
end
