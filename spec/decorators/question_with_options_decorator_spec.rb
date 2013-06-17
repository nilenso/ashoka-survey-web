require 'spec_helper'

describe QuestionWithOptionsDecorator do
  it "fetches options in the ascending order" do
    question = FactoryGirl.create(:radio_question)
    first_option = FactoryGirl.create(:option, :question_id => question.id, :order_number => 1)
    third_option = FactoryGirl.create(:option, :question_id => question.id, :order_number => 3)
    second_option = FactoryGirl.create(:option, :question_id => question.id, :order_number => 2)
    question.decorate.options.should == [first_option, second_option, third_option]
  end
end
