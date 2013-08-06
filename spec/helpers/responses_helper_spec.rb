require 'spec_helper'

Person = Struct.new(:name, :age)

describe ResponsesHelper do
  context "when merging arrays" do
    it "removes elements whose attributes are the same" do
      first = [Person.new("Foo", 15), Person.new("Bar", 17)]
      second = [Person.new("Foo", 15), Person.new("Bar", 19)]
      expect(merge_arrays_using_attributes(first, second, [:name, :age]).size).to eq(3)
    end

    it "doesn't remove elements whose attributes are not the same" do
      first = [Person.new("Foo", 15), Person.new("Bar", 17)]
      second = [Person.new("Bar", 15), Person.new("Bar", 19)]
      expect(merge_arrays_using_attributes(first, second, [:name, :age]).size).to eq(4)
    end
  end
end