require 'spec_helper'

describe Survey do
  context "when validating" do
    it { should validate_presence_of :name }
    it { should validate_presence_of :expiry_date }
  end
end
