require 'spec_helper'

describe DateQuestion do
  it "is a question with type = 'DateQuestion'" do
    DateQuestion.create!(:content => "hello", :order_number => 11)
    question = Question.find_by_content("hello")
    question.should be_a DateQuestion
    question.type.should == "DateQuestion"
  end

  it_behaves_like "a question"


  context "report_data" do
    it "generates report data" do
      date_question = DateQuestion.create!(:content => "some date question")
      date_question.answers << FactoryGirl.create( :answer_with_complete_response, :content=>"2010/02/21")
      date_question.answers << FactoryGirl.create( :answer_with_complete_response, :content=>"2012/01/11")
      date_question.report_data.should include(["2012/01/11", 1], ["2010/02/21", 1])
    end

    it "doesn't include answers of incomplete responses in the report data" do
      date_question = DateQuestion.create!(:content => "some date question")
      incomplete_response = FactoryGirl.create(:response, :status => "incomplete")
      date_question.answers << FactoryGirl.create(:answer_with_complete_response, :content=>"2010/02/21")
      date_question.answers << FactoryGirl.create(:answer, :content=>"2010/02/21", :response => incomplete_response)
      date_question.save
      date_question.report_data.should include(["2010/02/21", 1])
    end
  end
end
