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
      5.times { question.answers << FactoryGirl.create(:answer_with_complete_response, :content => question.options.first.content) }
      3.times { question.answers << FactoryGirl.create(:answer_with_complete_response, :content => question.options.last.content) }
      question.report_data.should include [question.options.first.content, 5]
      question.report_data.should include [question.options.last.content, 3]
    end

    it "returns an empty array if no answers belonging to a completed response exist for the question" do
      survey = FactoryGirl.create(:survey, :published => true, :organization_id => 1)
      question = RadioQuestion.find(FactoryGirl.create(:question_with_options).id)
      response = FactoryGirl.create(:response, :survey => survey, :organization_id => 1, :user_id => 2)
      FactoryGirl.create(:answer, :content => question.options.first.content, :response_id => response.id)
      question.report_data.should be_empty
    end
  end

  context "duplication" do
    it "duplicates its options when it is duplicated" do
      question = DropDownQuestion.find_by_id(FactoryGirl.create(:question_with_options, :type => 'DropDownQuestion').id)
      question.dup.options.should_not be_empty
    end
  end
end
