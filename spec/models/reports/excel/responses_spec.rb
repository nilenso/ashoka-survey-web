require "spec_helper"

describe Reports::Excel::Responses do
  it "includes the completed responses" do
    complete_response = FactoryGirl.create(:response, :status => "complete")
    incomplete_response = FactoryGirl.create(:response, :status => "incomplete")
    Reports::Excel::Responses.new(Response.scoped).build.all.should == [complete_response]
  end

  it "orders the responses by updated_at (earliest_first)" do
    new_response = FactoryGirl.create(:response, :status => "complete")
    old_response = Timecop.freeze(5.days.ago) { FactoryGirl.create(:response, :status => "complete") }
    Reports::Excel::Responses.new(Response.scoped).build.all.should == [old_response, new_response]
  end

  context "when filtering by date range" do
    it "includes the responses created within that date range" do
      from, to = (10.days.ago), (5.days.ago)
      response_before_range = Timecop.freeze(15.days.ago) { FactoryGirl.create(:response, :status => "complete") }
      response_within_range = Timecop.freeze(7.days.ago) { FactoryGirl.create(:response, :status => "complete") }
      response_after_range = Timecop.freeze(2.days.ago) { FactoryGirl.create(:response, :status => "complete") }
      Reports::Excel::Responses.new(Response.scoped).build(:from => from, :to => to).all.should == [response_within_range]
    end

    it "includes all the responses if no date range is passed in" do
      response_before_range = Timecop.freeze(15.days.ago) { FactoryGirl.create(:response, :status => "complete") }
      response_within_range = Timecop.freeze(7.days.ago) { FactoryGirl.create(:response, :status => "complete") }
      response_after_range = Timecop.freeze(2.days.ago) { FactoryGirl.create(:response, :status => "complete") }
      Reports::Excel::Responses.new(Response.scoped).build.all.should =~ [response_before_range, response_within_range, response_after_range]
    end

    it "includes all the responses if empty strings are passed in as the date range" do
      response_before_range = Timecop.freeze(15.days.ago) { FactoryGirl.create(:response, :status => "complete") }
      response_within_range = Timecop.freeze(7.days.ago) { FactoryGirl.create(:response, :status => "complete") }
      response_after_range = Timecop.freeze(2.days.ago) { FactoryGirl.create(:response, :status => "complete") }
      Reports::Excel::Responses.new(Response.scoped).build(:from => "", :to => "").all.should =~ [response_before_range, response_within_range, response_after_range]
    end
  end
end
