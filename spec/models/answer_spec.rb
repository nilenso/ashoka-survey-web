require 'spec_helper'

describe Answer do
  it { should respond_to(:content) }
  it { should belong_to(:question) }
  it { should validate_presence_of(:content) }
  it { should validate_presence_of(:question_id) }
end
