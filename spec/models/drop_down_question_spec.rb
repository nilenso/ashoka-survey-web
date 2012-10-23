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

  context "reports" do
    it "counts all its answers grouped by the option's content " do
      question = DropDownQuestion.find(FactoryGirl.create(:question_with_options, :type => 'DropDownQuestion').id)
      5.times { question.answers << FactoryGirl.create(:answer, :content => question.options.first.content) }
      3.times { question.answers << FactoryGirl.create(:answer, :content => question.options.last.content) }
      question.report_data.should include [question.options.first.content, 5]
      question.report_data.should include [question.options.last.content, 3]
    end
  end
end
