require 'spec_helper'

describe QuestionWithOptions do
  it { should have_many(:options).dependent(:destroy) }

  context 'when creating blank answers' do
    let(:response) { FactoryGirl.create :response }

    it "creates blank answers for each of its sub-questions" do
      question = RadioQuestion.find(FactoryGirl.create(:question_with_options).id)
      sub_question = FactoryGirl.create :question

      question.options[0].questions << sub_question
      question.create_blank_answers(:response_id => response.id)

      sub_question.answers.should_not be_blank
    end

    it "creates blank answers for the contents of each of its sub-categories" do
      question = RadioQuestion.find(FactoryGirl.create(:question_with_options).id)
      sub_category = FactoryGirl.create :category
      sub_question = FactoryGirl.create :question, :category => sub_category

      question.options[0].categories << sub_category
      question.create_blank_answers(:response_id => response.id)

      sub_question.answers.should_not be_blank
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

    it "includes its options" do
      question = RadioQuestion.find(FactoryGirl.create(:question_with_options).id)
      option = FactoryGirl.create(:option, :question_id => question.id)
      json = question.as_json_with_elements_in_order
      json['options'].size.should == question.options.size
    end
  end

  context "when fetching question with its sub_questions in order" do
    it "includes itself" do
      question = RadioQuestion.find(FactoryGirl.create(:question_with_options).id)
      question.questions_in_order.should include question
    end

    it "includes its options" do
      question = RadioQuestion.find(FactoryGirl.create(:question_with_options).id)
      option = FactoryGirl.create(:option, :question_id => question.id)
      sub_question = FactoryGirl.create(:question, :parent => option)
      question.questions_in_order.should include sub_question
    end
  end
end
