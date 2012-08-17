require 'spec_helper'

describe Response do
  it { should belong_to(:survey) }
  it { should have_many(:answers) }
  it { should validate_presence_of(:survey_id) }
  it { should accept_nested_attributes_for(:answers) }
end
