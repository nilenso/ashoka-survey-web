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

  context "when fetching sorted answers for a response" do
    let(:response) { FactoryGirl.create :response, :state => 'clean' }
    let(:answer) { FactoryGirl.create(:answer, :response_id => response.id) }
    let(:question) { MultiChoiceQuestion.create(:content => "hello", :order_number => 12345) }

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

  it_behaves_like "a question"
end
