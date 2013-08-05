require 'spec_helper'

describe QuestionWithOptions do
  context 'when initializing answers for a response' do
    let(:response) { FactoryGirl.create :response }

    it "initializes answers for each of its sub-questions" do
      question = FactoryGirl.create(:radio_question, :with_options)
      sub_question = FactoryGirl.create :question, :finalized, :parent => question.options[0]
      answers = question.find_or_initialize_answers_for_response(response)
      answers.map(&:question_id).should == [question.id, sub_question.id]
    end

    it "initializes answers for the contents of each of its sub-categories" do
      question = FactoryGirl.create(:radio_question, :with_options)
      sub_category = FactoryGirl.create :category, :parent => question.options[0]
      sub_question = FactoryGirl.create :question, :finalized, :category => sub_category
      answers = question.find_or_initialize_answers_for_response(response)
      answers.map(&:question_id).should == [question.id, sub_question.id]
    end

    it "initializes answers with a record_id if one is passed in" do
      question = FactoryGirl.create(:radio_question, :with_options)
      sub_question = FactoryGirl.create :question, :finalized, :parent => question.options[0]
      answers = question.find_or_initialize_answers_for_response(response, :record_id => 5)
      answers.map(&:record_id).should == [5, 5]
    end
  end


  context "report data" do
    it "returns an empty array if no answers are present" do
      FactoryGirl.create(:radio_question).report_data.should == []
    end

    it "returns an list of option names along with their counts" do
      question = FactoryGirl.create(:radio_question, :finalized)
      option = FactoryGirl.create(:option, :question => question, :content => "Foo")
      5.times do
        response = FactoryGirl.create(:response, :clean, :complete)
        FactoryGirl.create(:answer, :response => response, :question => question, :content => "Foo")
      end
      question.report_data.should == [["Foo", 5]]
    end
  end

  context "when fetching question with its elements in order as json" do
    it "includes itself" do
      question = RadioQuestion.find(FactoryGirl.create(:question_with_options).id)
      json = question.as_json_with_elements_in_order
      %w(type content id parent_id category_id).each do |attr|
        json[attr].should == question[attr]
      end
    end

    it "includes its options in ascending order" do
      question = FactoryGirl.create(:radio_question)
      first_option = FactoryGirl.create(:option, :question_id => question.id, :order_number => 1)
      third_option = FactoryGirl.create(:option, :question_id => question.id, :order_number => 3)
      second_option = FactoryGirl.create(:option, :question_id => question.id, :order_number => 2)
      json = question.as_json_with_elements_in_order
      json['options'].map { |o| o['id'] }.should == [first_option, second_option, third_option].map(&:id)
    end
  end

  context "when fetching question with its sub_questions in order" do
    it "includes itself" do
      question = RadioQuestion.find(FactoryGirl.create(:question_with_options).id)
      question.ordered_question_tree.should include question
    end

    it "includes its options" do
      question = RadioQuestion.find(FactoryGirl.create(:question_with_options).id)
      option = FactoryGirl.create(:option, :question_id => question.id)
      sub_question = FactoryGirl.create(:question, :parent => option)
      question.ordered_question_tree.should include sub_question
    end

    it "includes its options in ascending order" do
      question = FactoryGirl.create(:radio_question)
      first_option = FactoryGirl.create(:option, :question_id => question.id, :order_number => 1)
      second_option = FactoryGirl.create(:option, :question_id => question.id, :order_number => 2)
      first_sub_question = FactoryGirl.create(:question, :parent => first_option)
      second_sub_question = FactoryGirl.create(:question, :parent => second_option)
      question.ordered_question_tree.should == [question, first_sub_question, second_sub_question]
    end
  end
end
