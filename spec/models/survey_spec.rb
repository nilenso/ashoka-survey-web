require 'spec_helper'

describe Survey do
  it { should respond_to :name }
  it { should respond_to :expiry_date }
  it { should respond_to :description }
  it { should have_many(:questions).dependent(:destroy) }
  it { should have_many(:responses).dependent(:destroy) }
  it { should accept_nested_attributes_for :questions }

  context "when validating" do
    it { should validate_presence_of :name }
    it { should validate_presence_of :expiry_date }
    it "validates the expiry date to not be in the past" do
      date = Date.new(1990,10,24)
      survey = FactoryGirl.build(:survey, :expiry_date => date)
      survey.should_not be_valid
    end
  end

end
