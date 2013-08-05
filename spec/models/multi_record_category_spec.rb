require 'spec_helper'

describe MultiRecordCategory do
  it { should have_many :records }

  it "doesn't allow nested multi-record categories" do
    parent_mr = FactoryGirl.create(:multi_record_category)
    new_category = FactoryGirl.build(:multi_record_category, :category => parent_mr)
    new_category.should_not be_valid
  end

  context "when initializing answers for a new response" do
    let(:response) { FactoryGirl.create :response }

    it "does not create a record" do
      mr_category = FactoryGirl.create(:multi_record_category)
      expect {
        mr_category.find_or_initialize_answers_for_response(response)
      }.not_to change { Record.count }
    end

    it "initializes answers for each record in the given response" do
      mr_category = FactoryGirl.create(:multi_record_category)
      response = FactoryGirl.create(:response)
      first_record = FactoryGirl.create(:record, :response => response, :category => mr_category)
      second_record = FactoryGirl.create(:record, :response => response, :category => mr_category)

      question = FactoryGirl.create(:question, :finalized, :category => mr_category)
      answers = mr_category.find_or_initialize_answers_for_response(response)
      answers.map(&:record_id).should =~ [first_record.id, second_record.id]
    end
  end

  context "when fetching all child records that belong to a given response" do
    it "fetches all the records with the given response_id" do
      mr_category = FactoryGirl.create(:multi_record_category)
      record = FactoryGirl.create(:record, :category => mr_category, :response_id => 5)
      record_from_another_Response = FactoryGirl.create(:record, :category => mr_category, :response_id => 6)
      orphan_record = FactoryGirl.create(:record)
      mr_category.records_for_response(5).should == [record]
    end
  end
end
