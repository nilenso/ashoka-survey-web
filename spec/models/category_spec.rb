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
  it { should allow_mass_assignment_of :survey_id }
  it { should allow_mass_assignment_of :category_id }
  it { should allow_mass_assignment_of :parent_id }
  it { should allow_mass_assignment_of :order_number }

  it "fetches all it's sub-questions and sub-categories" do
    category = FactoryGirl.create :category
    category.questions << FactoryGirl.create_list(:question, 5)
    category.categories << FactoryGirl.create_list(:category, 5)
    category.elements.should == (category.questions + category.categories)
  end

  it "returns it's parent question" do
    question = DropDownQuestion.create({content: "Untitled question", survey_id: 18, order_number: 0})
    option = Option.create(content: "Option", order_number: 0)
    nested_category = FactoryGirl.create :category
    question.options << option
    option.categories << nested_category
    nested_category.parent_question.should == question
  end
end
