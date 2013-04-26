require 'spec_helper'

describe Reports::Excel::Row do
  it "can add elements to itself" do
    row = Reports::Excel::Row.new
    row << "Foo"
    row << "Bar"
    row.elements.should == ["Foo", "Bar"]
  end

  it "can add arrays of elements to itself" do
    row = Reports::Excel::Row.new
    row << %w(Foo Bar)
    row.elements.should == ["Foo", "Bar"]
  end

  it "initializes the base array with provided values" do
    row = Reports::Excel::Row.new(1,2)
    row << "Foo"
    row.elements.should == [1, 2, "Foo"]
  end

  it "returns a copy of its elements as an array" do
    row = Reports::Excel::Row.new(1,2)
    array = row.to_a
    array << 5
    row.to_a.should_not include 5
  end
end
