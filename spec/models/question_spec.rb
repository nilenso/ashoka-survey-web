require 'spec_helper'

describe Question do
    it { should allow_mass_assignment_of(:type) }
    it { should allow_mass_assignment_of(:parent_id) }
    it { should belong_to(:parent).class_name(Option) }

  context "validation" do
    it "allows multiple rows to have nil for order_number" do
      survey = FactoryGirl.create(:survey)
      FactoryGirl.create(:question, :order_number => nil, :survey_id => survey.id)
      another_question = FactoryGirl.build(:question, :order_number => nil, :survey_id => survey.id)
      another_question.should be_valid
    end
    it "ensures that the order number for a question is unique within a survey" do
      survey = FactoryGirl.create(:survey)
      question_1 = FactoryGirl.create(:question, :survey => survey, :order_number => 1)
      question_2 = FactoryGirl.build(:question, :survey => survey, :order_number => 1)
      question_2.should_not be_valid
    end

    it "ensures that the order number for a question is unique within its parent's scope" do
      survey = FactoryGirl.create(:survey)
      question_1 = FactoryGirl.create(:question, :survey => survey, :order_number => 1, :parent_id => 5)
      question_2 = FactoryGirl.build(:question, :survey => survey, :order_number => 1, :parent_id => 5)
      question_2.should_not be_valid
    end

    it "allows duplicate order numbers for questions with different parents within a survey" do
      survey = FactoryGirl.create(:survey)
      question_1 = FactoryGirl.create(:question, :survey => survey, :order_number => 1, :parent_id => 1)
      question_2 = FactoryGirl.create(:question, :survey => survey, :order_number => 1, :parent_id => 2)
      question_2.should be_valid
    end
  end

  context "orders by order number" do
    it "fetches all question in ascending order of order_number for a particular survey" do
      survey = FactoryGirl.create(:survey)
      question = FactoryGirl.create(:question, :survey => survey)
      another_question = FactoryGirl.create(:question, :survey => survey)
      survey.questions == [question, another_question]
      question.order_number.should be < another_question.order_number
    end
  end

  it "creates a question of a given type" do
    question_params = { content: "Untitled question", survey_id: 18, order_number: 1}
    type = "SingleLineQuestion"
    question = Question.new_question_by_type(type, question_params)
    question.class.name.should == "SingleLineQuestion"
  end
  
  include_examples 'a question'
end
