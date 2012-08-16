require 'spec_helper'

describe Survey do
  it { should respond_to :name }
  it { should respond_to :expiry_date }
  it { should respond_to :description }
  it { should have_many :questions }
  it { should accept_nested_attributes_for :questions }

  context "when validating" do
    it { should validate_presence_of :name }
    it { should validate_presence_of :expiry_date }
  end
end
