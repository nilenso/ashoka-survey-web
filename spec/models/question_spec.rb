require 'spec_helper'

describe Question do
  it { should allow_mass_assignment_of(:type) }
  it { should allow_mass_assignment_of(:parent_id) }
  it { should allow_mass_assignment_of(:identifier) }
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

  context "#json" do
    it "fetches all the questions nested directly under it for a RadioQuestion" do
      question = RadioQuestion.create({content: "Untitled question", survey_id: 18, order_number: 1})
      question.options << Option.create(content: "Option", order_number: 1)
      nested_question = SingleLineQuestion.create({content: "Nested", survey_id: 18, order_number: 1, parent_id: question.options.first.id})
      nested_json = nested_question.as_json(:methods => :type)
      # Need to do a #to_s because for some reason the direct hash comparison fails on ActiveSupport::TimeWithZone objects on Linux machines
      question.json[:options][0][:questions].map(&:to_s).should include nested_json.to_s
    end

    it "fetches all the questions nested directly under it for a DropDownQuestion" do
      question = DropDownQuestion.create({content: "Untitled question", survey_id: 18, order_number: 1})
      question.options << Option.create(content: "Option", order_number: 1)
      nested_question = SingleLineQuestion.create({content: "Nested", survey_id: 18, order_number: 1, parent_id: question.options.first.id})
      question.json[:options][0][:questions].map(&:to_s).should include nested_question.as_json(:methods => :type).to_s
    end

    it "returns self for all other types of questions" do
      question = Question.create({content: "Untitled question", survey_id: 18, order_number: 1})
      question.json.should include(question.as_json)
    end

    it "returns questions nested all levels below it" do
      question = RadioQuestion.create({content: "Untitled question", survey_id: 18, order_number: 1})
      question.options << Option.create(content: "Option", order_number: 2)
      nested_question = RadioQuestion.create({content: "Nested", survey_id: 18, order_number: 1, parent_id: question.options.first.id})
      nested_question.options << Option.create(content: "Nested Option", order_number: 1)
      second_nested_question = RadioQuestion.create({content: "Nested Again", survey_id: 18, order_number: 1, parent_id: nested_question.options.first.id})
      question.json[:options][0][:questions].map(&:to_s).should include(nested_question.json(:methods => :type).to_s)
      question.json[:options][0][:questions][0][:options][0][:questions].map(&:to_s).should include(second_nested_question.json(:methods => :type).to_s)
    end
  end

  it "knows if it is a first level question" do
    question = RadioQuestion.create({content: "Untitled question", survey_id: 18, order_number: 1})
    question.options << Option.create(content: "Option", order_number: 2)
    sub_question = RadioQuestion.create({content: "Nested", survey_id: 18, order_number: 1, parent_id: question.options.first.id})
    question.first_level?.should be_true
    sub_question.first_level?.should be_false
  end

  context "when returning all its subquestions in order" do
    it "returns itself and all its sub-questions in order for a RadioQuestion" do
      question = RadioQuestion.create({content: "Untitled question", survey_id: 18, order_number: 0})
      question.options << Option.create(content: "Option", order_number: 0)
      nested_question = RadioQuestion.create({content: "Nested", survey_id: 18, order_number: 0, parent_id: question.options.first.id})
      second_nested_question = RadioQuestion.create({content: "Nested", survey_id: 18, order_number: 1, parent_id: question.options.first.id})
      nested_question.options << Option.create(content: "Nested Option", order_number: 0)
      second_level_nested_question = RadioQuestion.create({content: "Nested Again", survey_id: 18, order_number: 0, parent_id: nested_question.options.first.id})
      question.with_sub_questions_in_order.should == [question, nested_question, second_level_nested_question, second_nested_question]
    end

    it "returns itself and all its sub-questions in order for a DropDownQuestion" do
      question = DropDownQuestion.create({content: "Untitled question", survey_id: 18, order_number: 0})
      question.options << Option.create(content: "Option", order_number: 0)
      nested_question = DropDownQuestion.create({content: "Nested", survey_id: 18, order_number: 0, parent_id: question.options.first.id})
      second_nested_question = DropDownQuestion.create({content: "Nested", survey_id: 18, order_number: 1, parent_id: question.options.first.id})
      nested_question.options << Option.create(content: "Nested Option", order_number: 0)
      second_level_nested_question = DropDownQuestion.create({content: "Nested Again", survey_id: 18, order_number: 0, parent_id: nested_question.options.first.id})
      question.with_sub_questions_in_order.should == [question, nested_question, second_level_nested_question, second_nested_question]
    end

    it "returns itself and all its sub-questions in order for a MultiChoiceQuestion" do
      question = MultiChoiceQuestion.create({content: "Untitled question", survey_id: 18, order_number: 0})
      question.options << Option.create(content: "Option", order_number: 0)
      nested_question = MultiChoiceQuestion.create({content: "Nested", survey_id: 18, order_number: 0, parent_id: question.options.first.id})
      second_nested_question = MultiChoiceQuestion.create({content: "Nested", survey_id: 18, order_number: 1, parent_id: question.options.first.id})
      nested_question.options << Option.create(content: "Nested Option", order_number: 0)
      second_level_nested_question = MultiChoiceQuestion.create({content: "Nested Again", survey_id: 18, order_number: 0, parent_id: nested_question.options.first.id})    
      question.with_sub_questions_in_order.should == [question, nested_question, second_level_nested_question, second_nested_question]
    end

    it "returns itself for all other types of questions" do
      question = SingleLineQuestion.create({content: "Untitled question", survey_id: 18, order_number: 0})
      question.with_sub_questions_in_order.should == [question]
    end
  end

  it "returns parent question of current child question" do
      question = DropDownQuestion.create({content: "Untitled question", survey_id: 18, order_number: 0})
      question.options << Option.create(content: "Option", order_number: 0)
      nested_question = DropDownQuestion.create({content: "Nested", survey_id: 18, order_number: 0, parent_id: question.options.first.id})
      nested_question.parent_question.should == question
  end

  it "returns its level of nesting" do
      question = DropDownQuestion.create({content: "Untitled question", survey_id: 18, order_number: 0})
      question.options << Option.create(content: "Option", order_number: 0)
      nested_question = DropDownQuestion.create({content: "Nested", survey_id: 18, order_number: 0, parent_id: question.options.first.id})
      nested_question.options << Option.create(content: "Option", order_number: 0)
      second_nested_question = DropDownQuestion.create({content: "Nested", survey_id: 18, order_number: 0, parent_id: nested_question.options.first.id})
      question.nesting_level.should == 1
      nested_question.nesting_level.should == 2
      second_nested_question.nesting_level.should == 3
  end

  context "reports" do
    it "has no report data" do
      FactoryGirl.create(:question).report_data.should be_empty
    end
  end

  context "Duplicate" do
    it "duplicates question with sub questions" do
      question = DropDownQuestion.create({content: "Untitled question", survey_id: 18, order_number: 0})
      question.options << Option.create(content: "Option", order_number: 0)
      nested_question = DropDownQuestion.create({content: "Nested", survey_id: 18, order_number: 0, parent_id: question.options.first.id})
      duplicated_question = question.duplicate(0)
      duplicated_question.id.should_not == question.id
      duplicated_question.content.should == question.content
      duplicated_question.options.first.questions.size.should == question.options.first.questions.size
    end

    it "sets the sub-questions' survey ID to the new survey's ID which is passed in" do
      question = DropDownQuestion.create({content: "Untitled question", survey_id: 18, order_number: 0})
      question.options << Option.create(content: "Option", order_number: 0)
      nested_question = DropDownQuestion.create({content: "Nested", survey_id: 18, order_number: 0, parent_id: question.options.first.id})
      duplicated_question = question.duplicate(18)
      duplicated_question.options[0].questions[0].survey_id.should == 18
    end
  end

  it "returns its image as a base64-encoded string" do
    question = FactoryGirl.create :question_with_image
    question.image_in_base64.should == Base64.encode64(File.read(question.image.path(:thumb)))
  end

  include_examples 'a question'
end
