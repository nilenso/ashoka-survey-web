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

  context "when fetching sorted answers for a response" do
    let(:response) { FactoryGirl.create :response }
    let(:answer) { FactoryGirl.create(:answer, :response_id => response.id) }
    let(:question) { RadioQuestion.create(:content => "hello", :order_number => 12345) }

    it "returns its answer for the specified response if it has no sub-elements" do
      question.answers << answer
      question.sorted_answers_for_response(response.id).should == [answer]
    end

    it "returns a sorted list of answers of itself and its sub questions for the specified response" do
      question.answers << answer
      option = FactoryGirl.create(:option, :question => question)

      sub_question = FactoryGirl.create(:question, :parent => option, :order_number => 1)
      sub_question_answer = FactoryGirl.create :answer, :response => response, :question => sub_question

      sub_category= FactoryGirl.create(:category, :parent => option, :order_number => 2)
      sub_category_question = FactoryGirl.create(:question, :category => sub_category)
      sub_category_question_answer = FactoryGirl.create :answer, :response => response, :question => sub_category_question

      question.sorted_answers_for_response(response.id).should == [answer, sub_question_answer, sub_category_question_answer]
    end
  end
end
