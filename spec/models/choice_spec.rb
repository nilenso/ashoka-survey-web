require 'spec_helper'

describe Choice do
  it { should respond_to :content }
  it { should belong_to :answer }
  it { should validate_presence_of :content }
end
