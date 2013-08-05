require 'spec_helper'

describe Option do
  it { should validate_presence_of(:content) }
  it { should validate_presence_of(:question_id) }

  context "scopes" do
    it "includes only finalized options" do
      finalized_option = FactoryGirl.create(:option, :finalized)
      non_finalized_option = FactoryGirl.create(:option)
      Option.finalized.should == [finalized_option]
    end
  end

  it "delegates `survey` to its parent question" do
    survey = FactoryGirl.create(:survey)
    option = FactoryGirl.create(:option, :question => FactoryGirl.create(:question, :survey => survey))
    option.survey.should == survey
  end

  context "validation" do
    it "Ensures that the order number for an option is unique within a question" do
      question = FactoryGirl.create(:radio_question)
      option_1 = FactoryGirl.create(:option, :question => question, :order_number => 1)
      option_2 = FactoryGirl.build(:option, :question => question, :order_number => 1)
      option_2.should_not be_valid
    end
  end

  context "callbacks" do
    context "when destroying" do
      context "if the survey is marked for deletion" do
        let(:question) { FactoryGirl.create(:question, :survey => FactoryGirl.create(:survey, :marked_for_deletion)) }

        it "destroys if it is finalized" do
          option = FactoryGirl.create(:option, :finalized, :question => question)
          expect { option.destroy }.to change { Option.count }.by(-1)
        end

        it "destroys if it is not finalized" do
          option = FactoryGirl.create(:option, :question => question)
          expect { option.destroy }.to change { Option.count }.by(-1)
        end
      end

      context "if the survey is not marked for deletion" do
        let(:question) { FactoryGirl.create(:question, :survey => FactoryGirl.create(:survey, :marked_for_deletion => false)) }

        it "doesn't destroy if it is finalized" do
          option = FactoryGirl.create(:option, :finalized, :question => question)
          expect { option.destroy }.not_to change { Option.count }
        end

        it "destroys if it is not finalized" do
          option = FactoryGirl.create(:option, :finalized => false, :question => question)
          expect { option.destroy }.to change { Option.count }.by(-1)
        end
      end
    end
  end

  it "fetches all option in ascending order of order_number for a particular question" do
    first_option = FactoryGirl.create(:option, :order_number => 1)
    third_option = FactoryGirl.create(:option, :order_number => 3)
    second_option = FactoryGirl.create(:option, :order_number => 2)
    Option.ascending.should == [first_option, second_option, third_option]
  end

  it "fetches all it's sub-questions and sub-categories" do
    option = FactoryGirl.create(:option)
    question = FactoryGirl.create :question, :order_number => 0
    category = FactoryGirl.create :category, :order_number => 1
    another_question = FactoryGirl.create :question, :order_number => 2
    option.questions << question
    option.categories << category
    option.questions << another_question

    option.elements.should == [question, category, another_question]
  end

  it "fetches all it's sub-questions and sub-categories with sub_questions" do
    option = FactoryGirl.create(:option)
    question = FactoryGirl.create :question, :order_number => 0
    category = FactoryGirl.create :category, :order_number => 1
    another_category = FactoryGirl.create :category, :order_number => 2
    another_question = FactoryGirl.create :question, :order_number => 2
    option.questions << question
    option.categories << category
    another_category.questions << FactoryGirl.create(:question)
    option.questions << another_question
    option.categories << another_category

    option.elements_with_questions.should == [question, another_question, another_category]
  end

  context "when fetching all the sub_questions of an option" do
    let(:question) { FactoryGirl.create :question }

    it "fetches the first level nested subquestions" do
      option = FactoryGirl.create(:option)
      nested_question_with_options = FactoryGirl.create(:radio_question, :with_options, :parent => option)
      another_nested_question = FactoryGirl.create(:radio_question, :parent => nested_question_with_options.options.first)
      option.as_json[:questions].map(&:to_json).should include nested_question_with_options.json(:methods => :type).to_json
      option.as_json[:questions].map(&:to_json).should_not include  another_nested_question.json(:methods => :type).to_json
    end

    it "returns itself when there are no sub_questions" do
      option = Option.create(content: "Option", order_number: 2, :question_id => question.id)
      option.as_json.should == option.as_json
    end

    it "includes the `has_multi_record_ancestor` method" do
      option = Option.create(content: "Option", order_number: 2, :question_id => question.id)
      option.as_json.should have_key(:has_multi_record_ancestor)
    end
  end

  context "reports" do
    it "counts the number of times it has been the answer to its question" do
      question = FactoryGirl.create :question, :finalized
      option = FactoryGirl.create(:option, :question => question)
      5.times { FactoryGirl.create(:answer_with_complete_response, :content => option.content, :question_id => option.question_id) }
      answers = question.answers
      option.report_data(answers).should == 5
    end
  end

  context "duplicate" do
    let(:survey) { FactoryGirl.create(:survey) }

    it "dupicates option" do
      option = FactoryGirl.create(:option, :content => "foo content")
      duplicated_option = option.duplicate(survey.id)
      duplicated_option.id.should_not == option.id
      duplicated_option.content.should == "foo content"
    end

    it "duplicates sub questions" do
      option = FactoryGirl.create(:option)
      question = FactoryGirl.create(:question, :parent => option, :content => "foo question")
      duplicated_option = option.duplicate(survey.id)
      duplicated_questions = duplicated_option.questions
      duplicated_questions.map(&:id).should_not include(question.id)
      duplicated_questions.map(&:content).should == ["foo question"]
      duplicated_questions.map(&:survey_id).should == [survey.id]
    end

    it "dupicates sub categories as well" do
      option = FactoryGirl.create(:option)
      category = FactoryGirl.create(:category, :content => "foo category", :parent => option)
      duplicated_option = option.duplicate(survey.id)
      duplicated_categories = duplicated_option.categories
      duplicated_categories.map(&:id).should_not include(category.id)
      duplicated_categories.map(&:content).should == ["foo category"]
      duplicated_categories.map(&:survey_id).should == [survey.id]
    end

    it "creates a non-finalized option, whether the original is finalized or not" do
      option = FactoryGirl.create(:option, :finalized)
      duplicate_option = option.duplicate(survey.id)
      duplicate_option.should_not be_finalized
    end
  end

  it "returns categories with questions" do
    option = FactoryGirl.create(:option)
    category = FactoryGirl.create(:category, :parent => option)
    another_category = FactoryGirl.create(:category)
    nested_question = FactoryGirl.create(:drop_down_question, :category => category)
    option.categories_with_questions.should include(category)
    option.categories_with_questions.should_not include(another_category)
  end

  context "#has_multi_record_ancestor" do
    it "returns true if its parent question belongs to a MultiRecordCategory" do
      mr_category = FactoryGirl.create(:multi_record_category)
      parent_question = FactoryGirl.create(:question_with_options, :category => mr_category)
      option = FactoryGirl.create(:option, :question => parent_question)
      option.should have_multi_record_ancestor
    end

    it "returns false if its parent question belongs to a regular category" do
      category = FactoryGirl.create(:category)
      parent_question = FactoryGirl.create(:question_with_options, :category => category)
      option = FactoryGirl.create(:option, :question => parent_question)
      option.should_not have_multi_record_ancestor
    end

    it "returns true if there is a multi-record category higher up in the chain" do
      mr_category = FactoryGirl.create(:multi_record_category)
      category = FactoryGirl.create(:category, :category => mr_category)
      question = FactoryGirl.create(:question_with_options, :category => category)
      option = FactoryGirl.create(:option, :question => question)
      option.should have_multi_record_ancestor
    end
  end

  context "when fetching an option with its elements in order as json" do
    it "includes itself" do
      option = FactoryGirl.create(:option)
      json = option.as_json_with_elements_in_order
      %w(content id question_id order_number).each do |attr|
        json[attr].should == option[attr]
      end
    end

    it "includes its sub elements" do
      option = FactoryGirl.create(:option)
      sub_question = FactoryGirl.create(:question, :parent => option)
      sub_category = FactoryGirl.create(:category, :parent => option)
      json = option.as_json_with_elements_in_order
      json['elements'].size.should == option.elements.size
    end
  end

  context "when fetching an option with its questions in order" do
    it "does not include itself" do
      option = FactoryGirl.create(:option)
      option.ordered_question_tree.should_not include option
    end

    it "includes its sub elements" do
      option = FactoryGirl.create(:option)
      sub_question = FactoryGirl.create(:question, :parent => option)
      option.ordered_question_tree.should == [sub_question]
    end
  end

  context "when finding or initializing answers for a response" do
    it "initializes answers for each of the option's sub-questions" do
      response = FactoryGirl.create(:response)
      option = FactoryGirl.create(:option)
      sub_question = FactoryGirl.create(:question, :parent => option)
      answers = option.find_or_initialize_answers_for_response(response)
      answers.first.question_id.should == sub_question.id
    end

    it "initializes answers with a record_id if one is passed in" do
      response = FactoryGirl.create(:response)
      option = FactoryGirl.create(:option)
      sub_question = FactoryGirl.create(:question, :parent => option)
      answers = option.find_or_initialize_answers_for_response(response, :record_id => 5)
      answers.first.record_id.should == 5
    end
  end
end
