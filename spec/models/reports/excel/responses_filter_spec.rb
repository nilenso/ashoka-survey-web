require "spec_helper"

describe Reports::Excel::ResponsesFilter do
  it "includes the completed responses" do
    complete_response = FactoryGirl.create(:response, :status => "complete")
    incomplete_response = FactoryGirl.create(:response, :status => "incomplete")
    Reports::Excel::ResponsesFilter.new(Response.scoped).filter.should == [complete_response]
  end

  it "orders the responses by updated_at (earliest_first)" do
    new_response = FactoryGirl.create(:response, :status => "complete")
    old_response = Timecop.freeze(5.days.ago) { FactoryGirl.create(:response, :status => "complete") }
    Reports::Excel::ResponsesFilter.new(Response.scoped).filter.should == [old_response, new_response]
  end
end
