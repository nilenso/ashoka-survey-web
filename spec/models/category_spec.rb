require 'spec_helper'

describe Category do
  it { should have_many :questions }
  it { should belong_to :category }
  it { should have_many :categories }
  it { should respond_to :content }
end
