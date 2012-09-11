require 'spec_helper'
describe ResponsesHelper do
  it "should return an appropriate hint based on numeric question range" do
    numeric_question_hint(1, 3).should include("1", "3")
    numeric_question_hint(1, nil).should include("1")
    numeric_question_hint(nil, 3).should include("3")
    numeric_question_hint(nil, nil).should be_nil
  end

  describe "#get_option_content_from_option_id" do
    it "gets the content of an option from its id" do
      option = FactoryGirl.create(:option, :content => 'abc')
      helper.get_option_content_from_option_id(option.id).should == 'abc'
    end

    it "returns nil for an invalid id" do
      helper.get_option_content_from_option_id(123).should be_nil
    end
  end
end
