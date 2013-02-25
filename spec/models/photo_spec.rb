require 'spec_helper'

describe Photo do
  it { should belong_to(:answer) }
end
