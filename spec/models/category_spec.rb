require 'spec_helper'

describe Category do
  it { should have_many(:questions).dependent(:destroy) }
  it { should have_many(:categories).dependent(:destroy) }
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


  it "includes the type when converting to JSON" do
    category = FactoryGirl.create :category
    category.as_json.keys.should include :type
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
end
