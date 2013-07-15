require 'spec_helper'

describe ResponseCounts do
  it 'finds the first count matching the given month' do
    response_count_1 = ResponseCount.new("May 2013", 1, 1)
    response_count_2 = ResponseCount.new("Jun 2013", 1, 1)
    counts = ResponseCounts.new([response_count_2, response_count_1])
    counts.find_by_month("May 2013").should == response_count_1
  end

  it "finds the unique months between two ResponseCounts objects" do
    response_counts_1 = ResponseCounts.new([ResponseCount.new("May 2013", 1, 1)])
    response_counts_2 = ResponseCounts.new([ResponseCount.new("May 2013", 1, 1), ResponseCount.new("June 2013", 1, 1)])
    response_counts_1.unique_months_between(response_counts_2).should == ["May 2013", "June 2013"]
  end

  it "adds ResponseCount objects to itself using <<" do
    response_count = ResponseCount.new("May 2013", 1, 1)
    response_counts = ResponseCounts.new
    response_counts << response_count
    response_counts.counts.should include response_count
  end

  context "when merging two ResponseCounts objects" do
    it "creates a ResponseCounts object combining duplicate months" do
      response_counts_1 = ResponseCounts.new([ResponseCount.new("May 2013", 2, 1)])
      response_counts_2 = ResponseCounts.new([ResponseCount.new("May 2013", 1, 5)])
      count = response_counts_1.merge(response_counts_2).counts[0]
      count.month.should == "May 2013"
      count.incompletes.should == 3
      count.completes.should == 6
    end

    it "counts months that are present in the other object that are not present in itself" do
      response_counts_1 = ResponseCounts.new([ResponseCount.new("May 2013", 2, 1)])
      response_counts_2 = ResponseCounts.new([ResponseCount.new("Jan 2013", 1, 5)])
      response_counts = response_counts_1.merge(response_counts_2)
      response_counts.counts.size.should == 2
    end

    it "only counts the other object's months if it is empty'" do
      response_counts_1 = ResponseCounts.new
      response_counts_2 = ResponseCounts.new([ResponseCount.new("Jan 2013", 1, 5)])
      response_counts = response_counts_1.merge(response_counts_2)
      response_counts.counts.size.should == 1
    end

    it "only counts its months if the other object is empty'" do
      response_counts_1 = ResponseCounts.new([ResponseCount.new("Jan 2013", 1, 5)])
      response_counts_2 = ResponseCounts.new
      response_counts = response_counts_1.merge(response_counts_2)
      response_counts.counts.size.should == 1
    end
  end

  context "when iterating over the ResponseCount objects" do
    it "yields all the counts" do
      response_count_1 = ResponseCount.new("Jan 2013", 1, 5)
      response_count_2 = ResponseCount.new("Jun 2013", 1, 5)
      response_counts = ResponseCounts.new([response_count_1, response_count_2])
      response_counts.each_in_reverse_chronological_order.to_a.should =~ [response_count_1, response_count_2]
    end

    it "yields the elements in reverse chronological order" do
      response_count_3 = ResponseCount.new("Jan 2013", 1, 5)
      response_count_2 = ResponseCount.new("Sep 2012", 1, 5)
      response_count_1 = ResponseCount.new("Jun 2013", 1, 5)
      response_counts = ResponseCounts.new([response_count_1, response_count_2, response_count_3])
      response_counts.each_in_reverse_chronological_order.to_a.should == [response_count_1, response_count_3, response_count_2]
    end
  end
end