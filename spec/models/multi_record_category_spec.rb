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
end
