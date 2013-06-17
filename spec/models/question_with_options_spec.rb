require 'spec_helper'

describe QuestionWithOptions do
  context 'when creating blank answers' do
    let(:response) { FactoryGirl.create :response }

    it "creates blank answers for each of its sub-questions" do
      question = FactoryGirl.create(:radio_question, :with_options)
      sub_question = FactoryGirl.create :question, :finalized, :parent => question.options[0]
      question.create_blank_answers(:response_id => response.id)
      sub_question.answers.should_not be_blank
    end

    it "creates blank answers for the contents of each of its sub-categories" do
      question = FactoryGirl.create(:radio_question, :with_options)
      sub_category = FactoryGirl.create :category, :parent => question.options[0]
      sub_question = FactoryGirl.create :question, :finalized, :category => sub_category
      question.create_blank_answers(:response_id => response.id)
      sub_question.answers.should_not be_blank
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
