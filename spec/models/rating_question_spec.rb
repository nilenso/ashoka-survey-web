require 'spec_helper'

describe RatingQuestion do
  it { should respond_to :max_length }
  
  it "is a question with type = 'RatingQuestion'" do
    RatingQuestion.create(:content => "hello")
    question = Question.find_by_content("hello")
    question.should be_a RatingQuestion
    question.type.should == "RatingQuestion"
  end

  it_behaves_like "a question"

  it_behaves_like "a question with max length"

  context "for report data" do
    let (:rating_question) { RatingQuestion.new(:content => "foo", :max_length => 10) }

    it "generates report data" do
      5.times { rating_question.answers << FactoryGirl.create(:answer_with_complete_response, :content=>'2') }
      3.times { rating_question.answers << FactoryGirl.create(:answer_with_complete_response, :content=>'5') }
      9.times { rating_question.answers << FactoryGirl.create(:answer_with_complete_response, :content=>'9') }
      rating_question.save
      rating_question.report_data.should == [[2, 5],[5, 3], [9, 9]]
    end

    it "gives 0 for min_value for reports" do
      rating_question.min_value_for_report.should == 0
    end

    it "gives max_value for miax_value for reports" do
      rating_question.max_value_for_report.should == rating_question.max_length
    end
  end
end
