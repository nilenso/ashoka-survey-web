require 'spec_helper'

describe Category do
  it { should have_many(:questions).dependent(:destroy) }
  it { should have_many(:categories).dependent(:destroy) }
  it { should have_many(:records).dependent(:destroy) }
  it { should belong_to(:parent).class_name(Option) }
  it { should belong_to :category }
  it { should belong_to :survey }
  it { should respond_to :content }
  it { should respond_to :order_number }

  it { should validate_presence_of :content }
  it { should allow_mass_assignment_of :content }
  it { should allow_mass_assignment_of :type }
  it { should allow_mass_assignment_of :survey_id }
  it { should allow_mass_assignment_of :category_id }
  it { should allow_mass_assignment_of :parent_id }
  it { should allow_mass_assignment_of :mandatory }
  it { should allow_mass_assignment_of :order_number }

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
    question = DropDownQuestion.create({content: "Untitled question", survey_id: 18, order_number: 0})
    option = Option.create(content: "Option", order_number: 0)
    nested_category = FactoryGirl.create :category
    question.options << option
    option.categories << nested_category
    nested_category.parent_question.should == question
  end

  it "knows if it (or one of it's parent categories) is a sub-question" do
    question = DropDownQuestion.create({content: "Untitled question", survey_id: 18, order_number: 0})
    option = Option.create(content: "Option", order_number: 0)
    nested_category = FactoryGirl.create :category
    second_level_category = FactoryGirl.create :category
    third_level_category = FactoryGirl.create :category
    question.options << option
    option.categories << nested_category
    nested_category.categories << second_level_category
    second_level_category.categories << third_level_category
    second_level_category.sub_question?.should be_true
    third_level_category.sub_question?.should be_true
    FactoryGirl.create(:category).sub_question?.should be_false
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

  context "Duplicate" do
    it "duplicates category with sub questions" do
      category = FactoryGirl.create :category, :order_number => 0
      nested_question = DropDownQuestion.create({content: "Nested", survey_id: 18, order_number: 0, category_id: category.id})
      duplicated_category = category.duplicate(0)
      duplicated_category.id.should_not == category.id
      duplicated_category.content.should == category.content
      duplicated_category.questions.size.should == category.questions.size
    end

    it "duplicates the nested sub categories as well" do
      category = FactoryGirl.create :category, :order_number => 0
      nested_category = FactoryGirl.create(:category, :category_id => category.id)
      duplicated_category = category.duplicate(0)
      duplicated_category.categories.size.should == category.categories.size
    end

    it "sets the sub-questions' survey ID to the new survey's ID which is passed in" do
      category = FactoryGirl.create :category, :order_number => 0
      nested_question = DropDownQuestion.create({content: "Nested", survey_id: 18, order_number: 0, category_id: category.id})
      duplicated_category = category.duplicate(18)
      duplicated_category.questions[0].survey_id.should == 18
    end
  end

  context "has any questions" do
    it "returns true if the category has sub questions" do
      category = FactoryGirl.create :category, :order_number => 0
      nested_question = DropDownQuestion.create({content: "Nested", survey_id: 18, order_number: 0, category_id: category.id})
      category.has_questions?.should be_true
    end

    it "returns true if the sub-category has sub questions" do
      category = FactoryGirl.create :category, :order_number => 0
      sub_category = FactoryGirl.create :category, :order_number => 1
      category.categories << sub_category
      nested_question = DropDownQuestion.create({content: "Nested", survey_id: 18, order_number: 0, category_id: sub_category.id})
      category.has_questions?.should be_true
    end

    it "returns true if the sub-category has sub questions" do
      category = FactoryGirl.create :category, :order_number => 0
      sub_category = FactoryGirl.create :category, :order_number => 1
      category.categories << sub_category
      category.has_questions?.should be_false
      sub_category.has_questions?.should be_false
    end

    it "returns categories with questions" do
      category = FactoryGirl.create :category, :order_number => 0
      sub_category = FactoryGirl.create :category, :order_number => 1
      category.categories << sub_category
      nested_question = DropDownQuestion.create({content: "Nested", survey_id: 18, order_number: 0, category_id: sub_category.id})
      category.categories_with_questions.should include(sub_category)
    end
  end

  it "returns the index of the parent's option amongst its siblings" do
    question = MultiChoiceQuestion.create({content: "Untitled question", survey_id: 18, order_number: 0})
    parent_option = Option.create(content: "Option", order_number: 0)
    question.options << parent_option
    question.options << Option.create(content: "Option", order_number: 1)
    question.options << Option.create(content: "Option", order_number: 2)
    sub_category = FactoryGirl.create :category, :order_number => 0
    parent_option.categories << sub_category
    sub_category.index_of_parent_option.should == 0
  end

  context "Copy" do
    it "assigns the correct order_number to the duplicated category" do
      category = FactoryGirl.create(:category)
      category.copy_with_order()
      Category.find_by_order_number(category.order_number + 1).should_not be_nil
    end

    it "duplicates category with sub questions" do
      category = FactoryGirl.create(:category)
      nested_question = DropDownQuestion.create({content: "Nested", survey_id: 18, order_number: 0, category_id: category.id})
      category.copy_with_order()
      duplicated_category = Category.find_by_order_number(category.order_number + 1)
      duplicated_category.id.should_not == category.id
      duplicated_category.content.should == category.content
      duplicated_category.questions.size.should == category.questions.size
    end

    it "sets the sub-questions' survey ID to the same survey_id as of the original question" do
      category = FactoryGirl.create(:category)
      nested_question = DropDownQuestion.create({content: "Nested", survey_id: 18, order_number: 0, category_id: category.id})
      category.copy_with_order()
      duplicated_category = Category.find_by_order_number(category.order_number + 1)
      duplicated_category.questions[0].survey_id.should == category.survey_id
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
    let(:response) { FactoryGirl.create :response }

    it "returns a sorted list of answers for all its elements for the specified response" do
      category= FactoryGirl.create(:category)

      category_question_1 = FactoryGirl.create(:question, :category => category, :order_number => 1)
      category_question_1_answer = FactoryGirl.create :answer, :response => response, :question => category_question_1

      category_question_2 = RadioQuestion.create(:content => "Foo", :order_number => 2)
      category.questions << category_question_2
      option = FactoryGirl.create(:option)
      category_question_2.options << option
      category_question_2_answer = FactoryGirl.create :answer, :response => response, :question => category_question_2

      category_question_2_sub_question = FactoryGirl.create(:question, :parent => option)
      category_question_2_sub_question_answer = FactoryGirl.create :answer, :response => response, :question => category_question_2_sub_question

      category.sorted_answers_for_response(response.id).should == [category_question_1_answer, category_question_2_answer, category_question_2_sub_question_answer]
    end
  end

  context "when creating empty answers for a new response" do
    let(:response) { FactoryGirl.create :response }

    it "creates empty answers for each of it's sub-questions" do
      category = FactoryGirl.create(:category)
      5.times { category.questions << FactoryGirl.create(:question) }
      category.create_blank_answers(:response_id => response.id)
      response.reload.answers.count.should == 5
    end

    it "creates empty answers for each of it's sub-categories' sub-questions" do
      category = FactoryGirl.create(:category)
      sub_category = FactoryGirl.create(:category, :category => category)
      5.times { sub_category.questions << FactoryGirl.create(:question) }
      category.create_blank_answers(:response_id => response.id)
      response.reload.answers.size.should == 5
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
      category.questions_in_order.should_not include category
    end

    it "includes its sub elements" do
      category = FactoryGirl.create(:category)
      sub_question = FactoryGirl.create(:question, :category => category)
      category.questions_in_order.should =~ [sub_question]
    end
  end
end
