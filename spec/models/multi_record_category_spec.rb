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
      5.times { mr_category.records << Record.create(:response_id => response.id) }
      mr_category.sorted_answers_for_response(response.id).size.should == 5
    end
  end
end
