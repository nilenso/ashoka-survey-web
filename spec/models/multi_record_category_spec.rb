require 'spec_helper'

describe MultiRecordCategory do
  it { should have_many :records }

  it "doesn't allow nested multi-record categories" do
    parent_mr = FactoryGirl.create(:multi_record_category)
    new_category = FactoryGirl.build(:multi_record_category, :category => parent_mr)
    new_category.should_not be_valid
  end

  context "when creating empty answers for a new response" do
    let(:response) { FactoryGirl.create :response }

    it "creates a new empty record" do
      mr_category = FactoryGirl.create(:multi_record_category)
      expect {
        mr_category.create_blank_answers(:response_id => response.id)
      }.to change { Record.count }.by 1
    end

    it "creates empty answers for the new record" do
      mr_category = FactoryGirl.create(:multi_record_category)
      question = FactoryGirl.create(:question, :finalized, :category => mr_category)
      mr_category.create_blank_answers(:response_id => response.id)
      question.answers.should_not be_empty
    end

    it "doesn't create a record if a record_id is passed in" do
      mr_category = FactoryGirl.create(:multi_record_category)
      question = FactoryGirl.create(:question, :category => mr_category)
      record = FactoryGirl.create(:record, :response => response, :category => mr_category)

      expect do
        mr_category.create_blank_answers(:record_id => record.id, :response_id => response.id)
      end.not_to change { Record.count }
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
