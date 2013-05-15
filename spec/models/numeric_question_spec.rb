require 'spec_helper'

describe NumericQuestion do
  it { should validate_numericality_of :max_value }
  it { should validate_numericality_of :min_value }

  it "is a question with type = 'NumericQuestion'" do
    question = FactoryGirl.create(:numeric_question)
    question.should be_a NumericQuestion
    question.type.should == "NumericQuestion"
  end

  it "should not allow a min-value greater than max-value" do
    numeric_question = FactoryGirl.build(:numeric_question, :content => "foo", :min_value => 5, :max_value => 2)
    numeric_question.should_not be_valid
    numeric_question.should have(1).error_on(:min_value)
  end

  it "should allow a min-value equal to the max-value" do
    numeric_question = FactoryGirl.create(:numeric_question, :content => "foo", :min_value => 5, :max_value => 5)
    numeric_question.should be_valid
  end

  it_behaves_like "a question"

  context "report_data" do
    it "generates report data" do
      numeric_question = FactoryGirl.create(:numeric_question, :finalized, :min_value => 0, :max_value => 10)
      5.times { FactoryGirl.create(:answer_with_complete_response, :content=>'2', :question => numeric_question) }
      3.times { FactoryGirl.create(:answer_with_complete_response, :content=>'5', :question => numeric_question) }
      9.times { FactoryGirl.create(:answer_with_complete_response, :content=>'9', :question => numeric_question) }
      numeric_question.report_data.should =~ [[2, 5],[5, 3], [9, 9]]
    end

    it "doesn't include answers of incomplete responses in the report data" do
      numeric_question = FactoryGirl.create(:numeric_question, :finalized, :min_value => 0, :max_value => 10)
      5.times { FactoryGirl.create(:answer_with_complete_response, :content=>'2', :question => numeric_question) }
      5.times { FactoryGirl.create(:answer, :content=>'2', :response => FactoryGirl.create(:response, :incomplete), :question => numeric_question) }
      numeric_question.report_data.should == [[2, 5]]
    end

    it "preserves floating point numbers" do
      numeric_question = FactoryGirl.create(:numeric_question, :finalized, :min_value => 0, :max_value => 10)
      FactoryGirl.create(:answer_with_complete_response, :content=>'2.5', :question => numeric_question)
      numeric_question.report_data.should == [[2.5, 1]]
    end
  end

  context "while returning min and max values for reporting" do
    let(:numeric_question) { FactoryGirl.create(:numeric_question, :finalized) }

    it "returns min value for the report" do
      numeric_question.min_value = 5
      numeric_question.min_value_for_report.should == 5
    end

    it "returns min value as 0 if it is not defined" do
      numeric_question.min_value_for_report.should == 0
    end

    it "returns max value for the report" do
      numeric_question.max_value = 10
      numeric_question.max_value_for_report.should == 10
    end

    it "returns max value as greatest answer for the question if it is not defined" do
      FactoryGirl.create(:answer_with_complete_response, :question => numeric_question, :content => 2)
      FactoryGirl.create(:answer_with_complete_response, :question => numeric_question, :content => 5)
      FactoryGirl.create(:answer_with_complete_response, :question => numeric_question, :content => 10)
      FactoryGirl.create(:answer_with_complete_response, :question => numeric_question, :content => 100)
      numeric_question.max_value_for_report.should == 100
    end

    it "returns 0 if there are no answers" do
      numeric_question.max_value_for_report.should == 0
    end
  end
end
