require 'spec_helper'

describe Sanitizer do
  it "removes blank params" do
    params = ["", "1", "2"]
    Sanitizer.clean_params(params).should == ["1", "2"]
  end
end
