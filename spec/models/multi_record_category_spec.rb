require 'spec_helper'

describe MultiRecordCategory do
  it "is a category with type = 'MultiRecordCategory'" do
    MultiRecordCategory.create(:content => "hello")
    category = Category.find_by_content("hello")
    category.should be_a MultiRecordCategory
    category.type.should == "MultiRecordCategory"
  end
end
