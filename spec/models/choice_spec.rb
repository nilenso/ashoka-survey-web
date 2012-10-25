require 'spec_helper'

describe Choice do
  it { should belong_to :option }
  it { should belong_to :answer }
  it { should allow_mass_assignment_of :option_id }

  it "gets it's content from the parent option" do
    choice = FactoryGirl.create :choice
    choice.content.should == choice.option.content
  end
end
