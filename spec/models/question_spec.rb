require 'spec_helper'

describe Question do
  it { should respond_to :content }
  it { should belong_to :survey }
  it { should have_many(:answers).dependent(:destroy) }
  it { should validate_presence_of :content }
  it { should respond_to :mandatory }
  it { should respond_to :image }
  it { should respond_to :max_length }
end
