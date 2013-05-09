require 'spec_helper'

shared_examples "a question with options" do |question_klass|

  let(:factory_name) { question_klass.to_s.underscore.to_sym }

  context "reports" do
    it "counts all its answers grouped by the option's content" do
      question = FactoryGirl.create(factory_name, :with_options)
      5.times { FactoryGirl.create(:answer_with_complete_response, :content => question.options.first.content, :question => question) }
      3.times { FactoryGirl.create(:answer_with_complete_response, :content => question.options.last.content, :question => question) }
      question.report_data.should include [question.options.first.content, 5]
      question.report_data.should include [question.options.last.content, 3]
    end

    it "returns an empty array if no answers belonging to a completed response exist for the question" do
      survey = FactoryGirl.create(:survey, :finalized)
      question = FactoryGirl.create(:radio_question, :with_options)
      response = FactoryGirl.create(:response, :survey => survey, :organization_id => 1, :user_id => 2)
      FactoryGirl.create(:answer, :content => question.options.first.content, :response_id => response.id)
      question.report_data.should be_empty
    end
  end

  context "when fetching sorted answers for a response" do
    let(:response) { FactoryGirl.create(:response) }
    let(:answer) { FactoryGirl.create(:answer, :response_id => response.id) }
    let(:question) { FactoryGirl.create(factory_name)}

    it "returns its answer for the specified response if it has no sub-elements" do
      question.answers << answer
      question.sorted_answers_for_response(response.id).should == [answer]
    end

    it "returns a sorted list of answers of itself and its sub questions for the specified response" do
      question.answers << answer
      option = FactoryGirl.create(:option, :question => question)

      sub_question = FactoryGirl.create(:question, :parent => option, :order_number => 1)
      sub_question_answer = FactoryGirl.create(:answer, :response => response, :question => sub_question)

      sub_category= FactoryGirl.create(:category, :parent => option, :order_number => 2)
      sub_category_question = FactoryGirl.create(:question, :category => sub_category)
      sub_category_question_answer = FactoryGirl.create(:answer, :response => response, :question => sub_category_question)

      question.sorted_answers_for_response(response.id).should == [answer, sub_question_answer, sub_category_question_answer]
    end
  end
end
