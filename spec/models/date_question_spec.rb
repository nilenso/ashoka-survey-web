require 'spec_helper'

describe DateQuestion do

  it "is a question with type = 'DateQuestion'" do
    DateQuestion.create!(:content => "hello", :order_number => 11)
    question = Question.find_by_content("hello")
    question.should be_a DateQuestion
    question.type.should == "DateQuestion"
  end

  it_behaves_like "a question"

  it "generates report data" do
    date_question = DateQuestion.create!(:content => "some date question")
    date_question.answers << FactoryGirl.create( :answer_with_complete_response, :content=>"2010/02/21")
    date_question.answers << FactoryGirl.create( :answer_with_complete_response, :content=>"2012/01/11")
    date_question.report_data.should == [["2012/01/11", 1], ["2010/02/21", 1]]
  end
end
