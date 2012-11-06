require 'spec_helper'

describe MultiChoiceQuestion do
  it { should have_many(:options).dependent(:destroy) }

  it "is a question with type = 'MultiChoiceQuestion'" do
    MultiChoiceQuestion.create(:content => "hello")
    question = Question.find_by_content("hello")
    question.should be_a MultiChoiceQuestion
    question.type.should == "MultiChoiceQuestion"
  end

  context "reports" do
    it "returns the number of answers grouped by option content" do
      question = MultiChoiceQuestion.find(FactoryGirl.create(:question_with_options, :type => 'MultiChoiceQuestion').id)
      5.times do
        answer = FactoryGirl.create(:answer_with_complete_response)
        answer.choices << FactoryGirl.create(:choice, :option => question.options.first)
        question.answers << answer
      end
      question.reload.report_data.should include [question.options.first.content, 5]
    end
  end

  context "duplication" do
    it "duplicates its options when it is duplicated" do
      question = MultiChoiceQuestion.find_by_id(FactoryGirl.create(:question_with_options, :type => 'MultiChoiceQuestion').id)
      question.dup.options.should_not be_empty
    end
  end

  it_behaves_like "a question"
end
