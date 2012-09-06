require 'spec_helper'

describe Question do
  it { should respond_to :content }
  it { should belong_to :survey }
  it { should have_many(:answers).dependent(:destroy) }
  it { should have_many(:options).dependent(:destroy) }
  it { should validate_presence_of :content }
  it { should respond_to :mandatory }
  it { should respond_to :image }
  it { should respond_to :max_length }
  it { should accept_nested_attributes_for(:options) }

  context "mass assignment" do
    it { should allow_mass_assignment_of(:content) }
    it { should allow_mass_assignment_of(:mandatory) }
    it { should allow_mass_assignment_of(:image) }
    it { should allow_mass_assignment_of(:max_length) }
    it { should allow_mass_assignment_of(:type) }
    it { should allow_mass_assignment_of(:max_value) }
    it { should allow_mass_assignment_of(:min_value) }
  end
end
