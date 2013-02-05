require 'spec_helper'

describe QuestionDecorator do
  it "returns the correct question_number for child questions" do
    survey = FactoryGirl.create(:survey)
    FactoryGirl.create(:question, :survey => survey, :order_number => 1)
    parent_question = FactoryGirl.create(:question_with_options, :survey => survey, :order_number => 3)
    parent_question = RadioQuestion.find(parent_question.id)
    FactoryGirl.create(:question, :survey => survey, :parent => parent_question.options.first, :order_number => 1)
    question = FactoryGirl.create(:question, :survey => survey, :parent => parent_question.options.first, :order_number => 3)
    QuestionDecorator.find(question).question_number == "2.2"
  end

  it "returns the correct question_number for child questions of category" do
    survey = FactoryGirl.create(:survey)
    FactoryGirl.create(:question, :survey => survey, :order_number => 1)
    category = FactoryGirl.create(:category, :survey => survey, :order_number => 3)
    question = FactoryGirl.create(:question, :survey => survey,:category => category,  :order_number => 3)
    QuestionDecorator.find(question).question_number == "2.1"
  end

  it "returns the correct question_number for sub questions of multi choice questions" do
    resp = FactoryGirl.create(:response)
    survey = FactoryGirl.create(:survey)

    question = MultiChoiceQuestion.create({content: "Untitled question", survey_id: survey.id, order_number: 0})
    parent_option = Option.create(content: "Option", order_number: 0)
    question.options << parent_option
    question.options << Option.create(content: "Option", order_number: 1)
    question.options << Option.create(content: "Option", order_number: 2)
    sub_question = SingleLineQuestion.create({content: "Untitled question", survey_id: survey.id, order_number: 0})
    parent_option.questions << sub_question

  QuestionDecorator.find(sub_question).question_number.should == '1A.1'
  end
end
