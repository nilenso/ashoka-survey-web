require 'spec_helper'

describe Category do
  it { should validate_presence_of :content }
  it { should_not have_many :records }

  context "scopes" do
    it "finds the finalized categories" do
      finalized_category = FactoryGirl.create(:category, :finalized)
      non_finalized_category = FactoryGirl.create(:category)
      Category.finalized.should == [finalized_category]
    end
  end

  context "callbacks" do
    context "when destroying" do
      context "if the survey is marked for deletion" do
        let(:survey) { FactoryGirl.create(:survey, :marked_for_deletion) }

        it "destroys if it is finalized" do
          category = FactoryGirl.create(:category, :finalized, :survey => survey)
          expect { category.destroy }.to change { Category.count }.by(-1)
        end

        it "destroys if it is not finalized" do
          category = FactoryGirl.create(:category, :survey => survey)
          expect { category.destroy }.to change { Category.count }.by(-1)
        end
      end

      context "if the survey is not marked for deletion" do
        let(:survey) { FactoryGirl.create(:survey, :marked_for_deletion => false) }

        it "doesn't destroy if it is finalized" do
          category = FactoryGirl.create(:category, :finalized, :survey => survey)
          expect { category.destroy }.not_to change { Category.count }
        end

        it "destroys if it is not finalized" do
          category = FactoryGirl.create(:category, :finalized => false, :survey => survey)
          expect { category.destroy }.to change { Category.count }.by(-1)
        end
      end
    end
  end

  it "fetches all it's sub-questions and sub-categories in order" do
    question = FactoryGirl.create :question, :order_number => 0
    category = FactoryGirl.create :category, :order_number => 1
    another_question = FactoryGirl.create :question, :order_number => 2
    category.questions << question
    category.categories << category
    category.questions << another_question
    category.elements.should == [question, category, another_question]
  end

  it "fetches all it's sub-questions and sub-categories with sub_questions" do
    category = FactoryGirl.create(:category)
    question = FactoryGirl.create :question, :order_number => 0
    one_category = FactoryGirl.create :category, :order_number => 1
    another_category = FactoryGirl.create :category, :order_number => 2
    another_question = FactoryGirl.create :question, :order_number => 2
    category.questions << question
    category.categories << one_category
    another_category.questions << FactoryGirl.create(:question)
    category.questions << another_question
    category.categories << another_category

    category.elements_with_questions.should == [question, another_question, another_category]
  end

  it "returns it's parent question" do
    question = FactoryGirl.create(:drop_down_question)
    option = FactoryGirl.create(:option, :question => question)
    nested_category = FactoryGirl.create(:category, :parent => option)
    nested_category.parent_question.should == question
  end

  it "knows if it (or one of it's parent categories) is a sub-question" do
    question = FactoryGirl.create(:drop_down_question)
    option = FactoryGirl.create(:option, :question => question)
    first_level_category = FactoryGirl.create(:category)
    second_level_category = FactoryGirl.create(:category, :parent => option)
    third_level_category = FactoryGirl.create(:category, :category => second_level_category)
    fourth_level_category = FactoryGirl.create(:category, :category => third_level_category)
    first_level_category.should_not be_sub_question
    second_level_category.should be_sub_question
    third_level_category.should be_sub_question
    fourth_level_category.should be_sub_question
  end

  context "when creating categories of the given type" do
    it "creates a regular category" do
      category = Category.new_category_by_type('', { :content => "cat" })
      category.should be_a Category
    end

    it "creates a MultiRecordCategory" do
      category = Category.new_category_by_type('MultiRecordCategory', { :content => "cat" })
      category.should be_a MultiRecordCategory
    end

    it "creates a new category with the given params" do
      category = Category.new_category_by_type('MultiRecordCategory', { :content => "cat" })
      category.content.should == 'cat'
    end
  end


  context "when converting to JSON" do
    it "includes the type" do
      category = FactoryGirl.create :category
      category.as_json.keys.should include :type
    end

    it "includes the `has_multi_record_ancestor` field" do
      category = FactoryGirl.create :category
      category.as_json.should have_key :has_multi_record_ancestor
    end

    context "#to_json_with_sub_elements" do
      it "includes it's sub elements" do
        category = FactoryGirl.create(:category)
        category.questions << FactoryGirl.create(:question)
        category.categories << FactoryGirl.create(:category)
        category_parsed = JSON.parse(category.to_json_with_sub_elements)
        category_parsed.should have_key('questions')
        category_parsed['questions'].size.should == category.questions.size
        category_parsed.should have_key('categories')
        category_parsed['categories'].size.should == category.categories.size
      end
    end
  end

  context "duplicate" do
    let(:survey) { FactoryGirl.create(:survey) }

    it "duplicates category" do
      category = FactoryGirl.create(:category, :content => "foo category")
      nested_question = DropDownQuestion.create({:survey_id => category.survey.id, :category_id => category.id})
      duplicated_category = category.duplicate(survey.id)
      duplicated_category.id.should_not == category.id
      duplicated_category.content.should == "foo category"
      duplicated_category.survey.id.should == survey.id
    end

    it "duplicates sub questions in a category" do
      category = FactoryGirl.create(:category)
      nested_question = DropDownQuestion.create({content: "foo question", :survey_id => category.survey.id, :category_id => category.id})
      duplicated_category = category.duplicate(survey.id)
      duplicated_questions = duplicated_category.questions
      duplicated_questions.map(&:id).should_not include(nested_question.id)
      duplicated_questions.map(&:survey_id).should == [survey.id]
      duplicated_questions.map(&:content).should == ["foo question"]
    end

    it "duplicates the nested sub categories as well" do
      category = FactoryGirl.create(:category)
      nested_category = FactoryGirl.create(:category, :content => "foo subcategory", :category_id => category.id, :survey => category.survey)
      duplicated_category = category.duplicate(survey.id)
      duplicated_sub_categories = duplicated_category.categories
      duplicated_sub_categories.map(&:id).should_not include(nested_category.id)
      duplicated_sub_categories.map(&:survey_id).should == [survey.id]
      duplicated_sub_categories.map(&:content).should == ["foo subcategory"]
    end

    it "creates a non-finalized category, whether the original is finalized or not" do
      category = FactoryGirl.create(:category, :finalized)
      duplicated_category = category.duplicate(survey.id)
      duplicated_category.should_not be_finalized
    end
  end

  context "has any questions" do
    it "returns true if the category has sub questions" do
      category = FactoryGirl.create(:category)
      nested_question = FactoryGirl.create(:drop_down_question, :category => category)
      category.should have_questions
    end

    it "returns true if the sub-category has sub questions" do
      category = FactoryGirl.create(:category)
      sub_category = FactoryGirl.create(:category, :category => category)
      nested_question = FactoryGirl.create(:drop_down_question, :category => sub_category)
      category.should have_questions
    end

    it "returns true if the sub-category has sub questions" do
      category = FactoryGirl.create :category, :order_number => 0
      sub_category = FactoryGirl.create :category, :order_number => 1
      category.categories << sub_category
      category.has_questions?.should be_false
      sub_category.has_questions?.should be_false
    end

    it "returns categories with questions" do
      category = FactoryGirl.create(:category)
      sub_category = FactoryGirl.create(:category, :category => category)
      nested_question = FactoryGirl.create(:drop_down_question, :category => sub_category)
      category.categories_with_questions.should == [sub_category]
    end
  end

  it "returns the index of the parent's option amongst its siblings" do
    question = FactoryGirl.create(:multi_choice_question)
    parent_option = FactoryGirl.create(:option, :question => question)
    FactoryGirl.create(:option, :question => question)
    FactoryGirl.create(:option, :question => question)
    sub_category = FactoryGirl.create(:category, :parent => parent_option)
    sub_category.index_of_parent_option.should == 0
  end

  context "Copy" do
    it "assigns the correct order_number to the duplicated category" do
      category = FactoryGirl.create(:category)
      category.copy_with_order
      Category.find_by_order_number(category.order_number + 1).should_not be_nil
    end

    it "duplicates category with sub questions" do
      category = FactoryGirl.create(:category, :content => "foo category")
      nested_question = FactoryGirl.create(:drop_down_question, :content => "foo question", :category => category, :order_number => 1)
      category.copy_with_order
      duplicated_category = Category.last
      duplicated_category.id.should_not == category.id
      duplicated_category.content.should == "foo category"
      duplicated_category.questions.map(&:content)== ["foo question"]
    end

    it "sets the sub-questions' survey ID to the same survey_id as of the original question" do
      survey = FactoryGirl.create(:survey)
      category = FactoryGirl.create(:category, :survey => survey, :order_number => 1)
      nested_question = FactoryGirl.create(:drop_down_question, :category => category)
      category.copy_with_order
      duplicated_category = Category.find_by_order_number(2)
      duplicated_category.questions.map(&:survey_id).should == [survey.id]
    end
  end

  context "#has_multi_record_ancestor?" do
    it "returns true if its parent option has a multi record ancestor" do
      mr_category = FactoryGirl.create(:multi_record_category)
      parent_question = FactoryGirl.create(:question_with_options, :category => mr_category)
      option = FactoryGirl.create(:option, :question => parent_question)
      question = FactoryGirl.create(:question, :parent => option)
      question.should have_multi_record_ancestor
    end

    it "returns false if its parent option doesn't have a multi record ancestor" do
      category = FactoryGirl.create(:category)
      parent_question = FactoryGirl.create(:question_with_options, :category => category)
      option = FactoryGirl.create(:option, :question => parent_question)
      question = FactoryGirl.create(:question, :parent => option)
      question.should_not have_multi_record_ancestor
    end

    it "returns true if its parent category has a multi record ancestor" do
      ancestor_category = FactoryGirl.create(:multi_record_category)
      category = FactoryGirl.create(:category, :category => ancestor_category)
      question = FactoryGirl.create(:question, :category => category)
      question.should have_multi_record_ancestor
    end

    it "returns false if its parent category doesn't have a multi record ancestor" do
      ancestor_category = FactoryGirl.create(:category)
      category = FactoryGirl.create(:category, :category => ancestor_category)
      question = FactoryGirl.create(:question, :category => category)
      question.should_not have_multi_record_ancestor
    end

    it "returns true if there is a multi-record category higher up in the chain" do
      mr_category = FactoryGirl.create(:multi_record_category)
      category = FactoryGirl.create(:category, :category => mr_category)
      question = FactoryGirl.create(:question_with_options, :category => category)
      option = FactoryGirl.create(:option, :question => question)
      option.should have_multi_record_ancestor
    end

    it "returns true if its parent category is a multi-record category" do
      category = FactoryGirl.create(:multi_record_category)
      question = FactoryGirl.create(:question, :category => category)
      question.should have_multi_record_ancestor
    end

    it "returns false if its parent category is not a multi-record category" do
      category = FactoryGirl.create(:category)
      question = FactoryGirl.create(:question, :category => category)
      question.should_not have_multi_record_ancestor
    end
  end


  context "when finding or initializing answers for a response" do
    let(:response) { FactoryGirl.create :response }

    it "initializes answers for each of it's sub-questions" do
      category = FactoryGirl.create(:category)
      questions = FactoryGirl.create_list(:question, 5, :finalized, :category => category)
      answers = category.find_or_initialize_answers_for_response(response)
      answers.map(&:question_id).should =~ questions.map(&:id)
    end

    it "initializes answers for each of it's sub-categories' sub-questions" do
      category = FactoryGirl.create(:category)
      sub_category = FactoryGirl.create(:category, :category => category)
      questions = FactoryGirl.create_list(:question, 5, :finalized, :category => category)
      answers = category.find_or_initialize_answers_for_response(response)
      answers.map(&:question_id).should =~ questions.map(&:id)
    end

    it "passes on the record_id if one is passed in" do
      category = FactoryGirl.create(:category)
      question = FactoryGirl.create(:question, :finalized, :category => category)
      answers = category.find_or_initialize_answers_for_response(response, :record_id => 5)
      answers.first.record_id.should == 5
    end
  end

  context "when fetching category with its elements in order as json" do
    it "includes itself" do
      category = FactoryGirl.create(:category)
      json = category.as_json_with_elements_in_order
      Category.attribute_names.each do |attr|
        json[attr].should == category[attr]
      end
    end

    it "includes its sub elements" do
      category = FactoryGirl.create(:category)
      sub_question = FactoryGirl.create(:question, :category => category)
      sub_category = FactoryGirl.create(:category, :category => category)
      json = category.as_json_with_elements_in_order
      json['elements'].size.should == category.elements.size
    end
  end

  context "when fetching a category's questions" do
    it "does not include itself" do
      category = FactoryGirl.create(:category)
      category.ordered_question_tree.should_not include category
    end

    it "includes its sub elements" do
      category = FactoryGirl.create(:category)
      sub_question = FactoryGirl.create(:question, :category => category)
      category.ordered_question_tree.should =~ [sub_question]
    end
  end
end
