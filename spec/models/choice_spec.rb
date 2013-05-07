require 'spec_helper'

describe Choice do
  it "gets it's content from the parent option" do
    choice = FactoryGirl.create :choice
    choice.content.should == choice.option.content
  end
end
