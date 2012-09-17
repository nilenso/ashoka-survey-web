require 'spec_helper'

describe Organization do
  subject { FactoryGirl.create(:organization)}
  it {should respond_to :name}
  it {should validate_presence_of :name}
  it {should validate_uniqueness_of :name}
end
