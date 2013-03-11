require 'spec_helper'

describe Question do
  it { should allow_mass_assignment_of(:type) }
  it { should allow_mass_assignment_of(:parent_id) }
  it { should allow_mass_assignment_of(:identifier) }
  it { should allow_mass_assignment_of(:category_id) }
  it { should belong_to(:parent).class_name(Option) }
  it { should belong_to(:category) }

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

    it "allows duplicate order numbers for questions with different parent categories within a survey" do
      survey = FactoryGirl.create(:survey)
      question_1 = FactoryGirl.create(:question, :survey => survey, :order_number => 1, :category_id => 1)
      question_2 = FactoryGirl.create(:question, :survey => survey, :order_number => 1, :category_id => 2)
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
      nested_json = nested_question.as_json(:methods => [:type, :options])
      # Need to do a #to_s because for some reason the direct hash comparison fails on ActiveSupport::TimeWithZone objects on Linux machines
      question.json[:options][0][:questions].map(&:to_s).should include nested_json.to_s
    end

    it "fetches all the questions nested directly under it for a DropDownQuestion" do
      question = DropDownQuestion.create({content: "Untitled question", survey_id: 18, order_number: 1})
      question.options << Option.create(content: "Option", order_number: 1)
      nested_question = SingleLineQuestion.create({content: "Nested", survey_id: 18, order_number: 1, parent_id: question.options.first.id})
      question.json[:options][0][:questions].map(&:to_s).should include nested_question.as_json(:methods => [:type, :options]).to_s
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
    category = FactoryGirl.create(:category)
    question.options << Option.create(content: "Option", order_number: 2)
    sub_question = RadioQuestion.create({content: "Nested", survey_id: 18, order_number: 1, parent_id: question.options.first.id})
    question_under_category = FactoryGirl.create(:question, :category => category)
    question.first_level?.should be_true
    sub_question.first_level?.should be_false
    question_under_category.first_level?.should be_false
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

  context "when returning it's level of nesting" do
    it "takes into account nesting under an option" do
      question = DropDownQuestion.create({content: "Untitled question", survey_id: 18, order_number: 0})
      question.options << Option.create(content: "Option", order_number: 0)
      nested_question = DropDownQuestion.create({content: "Nested", survey_id: 18, order_number: 0, parent_id: question.options.first.id})
      nested_question.options << Option.create(content: "Option", order_number: 0)
      second_nested_question = DropDownQuestion.create({content: "Nested", survey_id: 18, order_number: 0, parent_id: nested_question.options.first.id})
      question.nesting_level.should == 1
      nested_question.nesting_level.should == 2
      second_nested_question.nesting_level.should == 3
    end

    it "takes into account nesting under a category" do
      question = DropDownQuestion.create({content: "Untitled question", survey_id: 18, order_number: 0})
      option = Option.create(content: "Option", order_number: 0)
      nested_question = FactoryGirl.create :question
      question.options << option
      category = FactoryGirl.create :category
      option.categories << category
      category.questions << nested_question
      question.nesting_level.should == 1
      nested_question.nesting_level.should == 3
    end
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

  it "returns the index of the parent's option amongst its siblings" do
      question = MultiChoiceQuestion.create({content: "Untitled question", survey_id: 18, order_number: 0})
      parent_option = Option.create(content: "Option", order_number: 0)
      question.options << parent_option
      question.options << Option.create(content: "Option", order_number: 1)
      question.options << Option.create(content: "Option", order_number: 2)
      sub_question = SingleLineQuestion.create({content: "Untitled question", survey_id: 18, order_number: 0})
      parent_option.questions << sub_question
      sub_question.index_of_parent_option.should == 0
  end

  context "Copy" do
    it "assigns the correct order_number to the duplicated question" do
      question = FactoryGirl.create(:question)
      question.copy_with_order()
      Question.find_by_order_number(question.order_number + 1).should_not be_nil
    end

    it "duplicates question with sub questions" do
      question = DropDownQuestion.create({content: "Untitled question", survey_id: 18, order_number: 0})
      question.options << Option.create(content: "Option", order_number: 0)
      nested_question = DropDownQuestion.create({content: "Nested", survey_id: 18, order_number: 0, parent_id: question.options.first.id})
      question.copy_with_order()
      duplicated_question = Question.find_by_order_number(question.order_number + 1)
      duplicated_question.id.should_not == question.id
      duplicated_question.content.should == question.content
      duplicated_question.options.first.questions.size.should == question.options.first.questions.size
    end

    it "sets the sub-questions' survey ID to the same survey_id as of the original question" do
      question = DropDownQuestion.create({content: "Untitled question", survey_id: 18, order_number: 0})
      question.options << Option.create(content: "Option", order_number: 0)
      nested_question = DropDownQuestion.create({content: "Nested", survey_id: 18, order_number: 0, parent_id: question.options.first.id})
      question.copy_with_order()
      duplicated_question = Question.find_by_order_number(question.order_number + 1)
      duplicated_question.options[0].questions[0].survey_id.should == question.survey_id
    end
  end

  context "#has_multi_record_ancestor?" do
    it "returns true if its parent option has a multi record ancestor" do
      mr_category = MultiRecordCategory.create(:content => "MR")
      parent_question = FactoryGirl.create(:question_with_options, :category => mr_category)
      option = FactoryGirl.create(:option, :question => parent_question)
      question = FactoryGirl.create(:question, :parent => option)
      question.should have_multi_record_ancestor
    end

    it "returns false if its parent option doesn't have a multi record ancestor" do
      category = Category.create(:content => "Cat")
      parent_question = FactoryGirl.create(:question_with_options, :category => category)
      option = FactoryGirl.create(:option, :question => parent_question)
      question = FactoryGirl.create(:question, :parent => option)
      question.should_not have_multi_record_ancestor
    end

    it "returns true if its parent category has a multi record ancestor" do
      ancestor_category = MultiRecordCategory.create(:content => "Anc")
      category = FactoryGirl.create(:category, :category => ancestor_category)
      question = FactoryGirl.create(:question, :category => category)
      question.should have_multi_record_ancestor
    end

    it "returns false if its parent category doesn't have a multi record ancestor" do
      ancestor_category = Category.create(:content => "Anc")
      category = FactoryGirl.create(:category, :category => ancestor_category)
      question = FactoryGirl.create(:question, :category => category)
      question.should_not have_multi_record_ancestor
    end

    it "returns true if there is a multi-record category higher up in the chain" do
      mr_category = MultiRecordCategory.create(:content => "MR")
      category = FactoryGirl.create(:category, :category => mr_category)
      question = FactoryGirl.create(:question_with_options, :category => category)
      option = FactoryGirl.create(:option, :question => question)
      option.should have_multi_record_ancestor
    end

    it "returns true if its parent category is a multi-record category" do
      category = MultiRecordCategory.create(:content => "MR")
      question = FactoryGirl.create(:question, :category => category)
      question.should have_multi_record_ancestor
    end

    it "returns false if its parent category is not a multi-record category" do
      category = Category.create(:content => "Cat")
      question = FactoryGirl.create(:question, :category => category)
      question.should_not have_multi_record_ancestor
    end
  end

  context "when fetching sorted answers for a response" do
    let(:question) { FactoryGirl.create :question }
    let(:response) { FactoryGirl.create :response }

    it "returns its answer for the specified response" do
      response_1 = FactoryGirl.create :response
      response_2 = FactoryGirl.create :response
      answer = FactoryGirl.create(:answer, :content => "Second", :response => response_2)
      question.answers << FactoryGirl.create(:answer, :content => "First", :response => response_1)
      question.answers << answer
      question.sorted_answers_for_response(response_2.id).should == [answer]
    end

    it "returns its answer for the specified record" do
      mr_category = MultiRecordCategory.create(:content => "MR")
      question = FactoryGirl.create :question, :category => mr_category

      record_1 = FactoryGirl.create :record, :category => mr_category, :response => response
      record_2 = FactoryGirl.create :record, :category => mr_category, :response => response

      answer_1 = Answer.create(:response_id => response.id, :record_id => record_1.id, :question_id => question.id)
      answer_2 = Answer.create(:response_id => response.id, :record_id => record_2.id, :question_id => question.id)

      question.sorted_answers_for_response(response.id, record_1).should == [answer_1.reload]
      question.sorted_answers_for_response(response.id, record_2).should == [answer_2.reload]
    end

    it "returns an empty array if an invalid response_id is passed in" do
      question.sorted_answers_for_response(42).should == []
    end
  end

  context "when creating empty answers for a new response" do
    let(:response) { FactoryGirl.create :response }

    it "creates an empty answer to itself" do
      question = FactoryGirl.create(:question)
      question.create_blank_answers(:response_id => response.id)
      response.reload.answers.should_not be_empty
    end

    it "creates an empty answer belonging to a record (if specified)" do
      record = FactoryGirl.create(:record)
      question = FactoryGirl.create(:question)
      question.create_blank_answers(:response_id => response.id, :record_id => record.id)
      record.reload.answers.should_not be_empty
    end

    it "creates the empty answer without running validations" do
      question = FactoryGirl.create(:question, :max_length => 5)
      expect { question.create_blank_answers(:response_id => response.id) }.not_to raise_error
      response.reload.answers.should_not be_empty
    end
  end

  it "returns an empty array if a question doesn't have option" do
    question = FactoryGirl.create(:question, :max_length => 5)
    question.options.should be_empty
  end

  include_examples 'a question'
end
