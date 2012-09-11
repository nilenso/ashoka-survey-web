require 'spec_helper'

describe ResponsesHelper do
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
