require 'spec_helper'

describe DateQuestion do
  it_behaves_like "a question"

  context "report_data" do
    it "generates report data" do
      date_question = FactoryGirl.create(:date_question, :finalized)
      FactoryGirl.create( :answer_with_complete_response, :content=>"2010/02/21", :question => date_question)
      FactoryGirl.create( :answer_with_complete_response, :content=>"2012/01/11", :question => date_question)
      date_question.report_data.should include(["2012/01/11", 1], ["2010/02/21", 1])
    end

    it "doesn't include answers of incomplete responses in the report data" do
      date_question = FactoryGirl.create(:date_question, :finalized)
      incomplete_response = FactoryGirl.create(:response, :status => "incomplete")
      FactoryGirl.create(:answer_with_complete_response, :content=>"2010/02/21", :question => date_question)
      FactoryGirl.create(:answer, :content=>"2010/02/21", :response => incomplete_response, :question => date_question)
      date_question.report_data.should include(["2010/02/21", 1])
    end
  end
end
