require 'spec_helper'

describe RatingQuestion do
  it_behaves_like "a question"

  it_behaves_like "a question with max length"

  context "for report data" do
    let (:rating_question) { FactoryGirl.create(:rating_question, :finalized, :max_length => 10) }

    it "generates report data" do
      5.times { FactoryGirl.create(:answer_with_complete_response, :content=>'2', :question => rating_question) }
      3.times { FactoryGirl.create(:answer_with_complete_response, :content=>'5', :question => rating_question) }
      9.times { FactoryGirl.create(:answer_with_complete_response, :content=>'9', :question => rating_question) }
      rating_question.save
      rating_question.report_data.should =~ [[2, 5],[5, 3], [9, 9]]
    end

    it "doesn't include answers of incomplete responses in the report data" do
      5.times { FactoryGirl.create(:answer_with_complete_response, :content=>'2', :question => rating_question) }
      5.times { FactoryGirl.create(:answer, :content=>'2', :response => FactoryGirl.create(:response, :incomplete), :question => rating_question) }
      rating_question.save
      rating_question.report_data.should == [[2, 5]]
    end

    it "gives 0 for min_value for reports" do
      rating_question.min_value_for_report.should == 0
    end

    it "gives max_value for miax_value for reports" do
      rating_question.max_value_for_report.should == rating_question.max_length
    end
  end
end
