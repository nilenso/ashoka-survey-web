require 'spec_helper'

describe CategoryDecorator do
  it "returns the correct question_number for parent categories" do
    survey = FactoryGirl.create(:survey)
    FactoryGirl.create(:question, :order_number => 1)
    category = FactoryGirl.create(:category, :survey => survey, :order_number => 2)
    category.questions << FactoryGirl.create(:question)
    CategoryDecorator.find(category).question_number == "2"
  end

  it "returns the correct question_number for sub category" do
    survey = FactoryGirl.create(:survey)
    FactoryGirl.create(:question, :order_number => 1)
    category = FactoryGirl.create(:category, :survey => survey, :order_number => 2)
    sub_category = FactoryGirl.create(:category, :survey => survey,:category => category)
    sub_category.questions << FactoryGirl.create(:question)
    CategoryDecorator.find(sub_category).question_number == "2.1"
  end
end
