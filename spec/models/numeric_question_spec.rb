require 'spec_helper'

describe NumericQuestion do
  it { should respond_to :max_value }
  it { should respond_to :min_value }

  it "is a question with type = 'NumericQuestion'" do
    NumericQuestion.create(:content => "hello",:order_number => 11)
    question = Question.find_by_content("hello")
    question.should be_a NumericQuestion
    question.type.should == "NumericQuestion"
  end

  it "should not allow a min-value greater than max-value" do
    numeric_question = NumericQuestion.new(:content => "foo", :min_value => 5, :max_value => 2)
    numeric_question.should_not be_valid
  end

  it "should allow a min-value equal to the max-value" do
    numeric_question = NumericQuestion.new(:content => "foo", :min_value => 5, :max_value => 5)
    numeric_question.should be_valid
  end

  it_behaves_like "a question"

  it "generates report data" do
    numeric_question = NumericQuestion.new(:content => "foo", :min_value => 0, :max_value => 10)
    5.times { numeric_question.answers << FactoryGirl.create(:answer_with_complete_response, :content=>2) }
    3.times { numeric_question.answers << FactoryGirl.create(:answer_with_complete_response, :content=>5) }
    9.times { numeric_question.answers << FactoryGirl.create(:answer_with_complete_response, :content=>9) }
    numeric_question.save
    numeric_question.report_data.should == [[2, 5],[5, 3], [9, 9]]
  end
end
