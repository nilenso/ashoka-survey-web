require 'spec_helper'

describe MultiChoiceQuestion do
  it_behaves_like "a question"

  context "reports" do
    it "returns the number of answers grouped by option content" do
      question = FactoryGirl.create(:multi_choice_question, :finalized, :with_options)
      5.times do
        response = FactoryGirl.create(:response, :clean, :complete)
        answer = FactoryGirl.create(:answer, :response => response, :question => question)
        answer.choices << FactoryGirl.create(:choice, :option => question.options.first)
      end
      question.reload.report_data.should include [question.options.first.content, 5]
    end

    it "returns an empty array if no answers are present" do
      question = FactoryGirl.create(:multi_choice_question, :finalized, :with_options)
      question.report_data.should == []
    end
  end

  context "when fetching sorted answers for a response" do
    let(:response) { FactoryGirl.create :response, :state => 'clean' }
    let(:question) { FactoryGirl.create(:multi_choice_question, :finalized) }

    it "returns its answer for the specified response if it has no sub-elements" do
      answer = FactoryGirl.create(:answer, :response_id => response.id, :question => question)
      question.sorted_answers_for_response(response.id).should == [answer]
    end

    it "returns a sorted list of answers of itself and its sub questions for the specified response" do
      answer = FactoryGirl.create(:answer, :response_id => response.id, :question => question)
      option = FactoryGirl.create(:option, :question => question)

      sub_question = FactoryGirl.create(:question, :finalized, :parent => option, :order_number => 1)
      sub_question_answer = FactoryGirl.create(:answer, :response => response, :question => sub_question)

      sub_category= FactoryGirl.create(:category, :parent => option, :order_number => 2)
      sub_category_question = FactoryGirl.create(:question, :finalized, :category => sub_category)
      sub_category_question_answer = FactoryGirl.create(:answer, :response => response, :question => sub_category_question)

      question.sorted_answers_for_response(response.id).should == [answer, sub_question_answer, sub_category_question_answer]
    end
  end
end
