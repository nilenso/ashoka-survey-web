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
end
