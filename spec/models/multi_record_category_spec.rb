require 'spec_helper'

describe MultiRecordCategory do
  it "is a category with type = 'MultiRecordCategory'" do
    MultiRecordCategory.create(:content => "hello")
    category = Category.find_by_content("hello")
    category.should be_a MultiRecordCategory
    category.type.should == "MultiRecordCategory"
  end

  it "doesn't allow nested multi-record categories" do
    parent_mr = MultiRecordCategory.create(:content => "mr")
    expect do
      MultiRecordCategory.create(:content => "child_mr", :category_id => parent_mr.id)
    end.not_to change { MultiRecordCategory.count }
  end

  context "when sorting answers for a response" do
    let(:response) { FactoryGirl.create :response }

    it "returns answers for each of its records" do
      mr_category = MultiRecordCategory.create(:content => "MR")
      question = FactoryGirl.create :question, :category => mr_category
      5.times do
        record = Record.create(:response_id => response.id)
        mr_category.records << record
        record.answers << FactoryGirl.create(:answer, :question => question, :response => response)
      end

      mr_category.sorted_answers_for_response(response.id).size.should == 5
    end

    it "includes records belonging only to the specified response" do
      another_response = FactoryGirl.create :response
      mr_category = MultiRecordCategory.create(:content => "MR")
      question = FactoryGirl.create :question, :category => mr_category

      5.times do
        record = Record.create(:response_id => response.id)
        mr_category.records << record
        record.answers << FactoryGirl.create(:answer, :question => question, :response => response)
      end

      5.times do
        record = Record.create(:response_id => another_response.id)
        mr_category.records << record
        record.answers << FactoryGirl.create(:answer, :question => question, :response => another_response)
      end

      mr_category.sorted_answers_for_response(response.id).size.should == 5      
    end
  end

  context "when creating empty answers for a new response" do
    let(:response) { FactoryGirl.create :response }

    it "creates a new empty record" do
      mr_category = MultiRecordCategory.create(:content => "MR")
      expect {
        mr_category.create_blank_answers(:response_id => response.id)
      }.to change { Record.count }.by 1
    end

    it "creates empty answers for the new record" do
      mr_category = MultiRecordCategory.create(:content => "MR")
      question = FactoryGirl.create :question
      mr_category.questions << question

      mr_category.create_blank_answers(:response_id => response.id)
      question.reload.answers.should_not be_empty
    end
  end
end
