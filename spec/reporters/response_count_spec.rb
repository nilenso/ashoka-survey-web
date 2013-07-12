require 'spec_helper'

describe ResponseCount do
  context "when merging with another ResponseCount" do
    it "adds up the incompletes" do
      response_count_1 = ResponseCount.new("May 2013", 5, 5)
      response_count_2 = ResponseCount.new("May 2013", 6, 5)
      response_count_1.merge(response_count_2).incompletes.should == 11
    end

    it "adds up the completes" do
      response_count_1 = ResponseCount.new("May 2013", 5, 5)
      response_count_2 = ResponseCount.new("May 2013", 6, 5)
      response_count_1.merge(response_count_2).completes.should == 10
    end


    it "duplicates itself if `other` is nil" do
      response_count = ResponseCount.new("May 2013", 5, 5)
      duplicated_count = response_count.merge(nil)
      duplicated_count.incompletes.should == 5
      duplicated_count.completes.should == 5
    end
  end
end