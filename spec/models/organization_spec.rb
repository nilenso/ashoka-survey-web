require 'spec_helper'

describe Organization do
  subject { FactoryGirl.create(:organization)}
  it {should respond_to :name}
  it {should validate_presence_of :name}
  it {should validate_uniqueness_of :name}
  it {should have_many :surveys}

  it "stores organizations if they do not exist" do
    Organization.sync([{'id' => '1', 'name' => 'orgname'}])
    Organization.find(1).should_not be_nil
  end
end
