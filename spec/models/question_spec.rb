require 'spec_helper'

describe Question do
  it { should respond_to :content }
  it { should belong_to :survey }
  it { should validate_presence_of :content }
end
