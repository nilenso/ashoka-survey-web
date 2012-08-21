require 'spec_helper'

describe Response do
  it { should belong_to(:survey) }
  it { should have_many(:answers).dependent(:destroy) }
  it { should accept_nested_attributes_for(:answers) }
end
