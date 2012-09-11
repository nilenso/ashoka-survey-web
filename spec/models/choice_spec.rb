require 'spec_helper'

describe Choice do
  it { should belong_to :option }
  it { should belong_to :answer }
end
