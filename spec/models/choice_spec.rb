require 'spec_helper'

describe Choice do
  it { should belong_to :option }
  it { should belong_to :answer }
  it { should allow_mass_assignment_of :option_id }
end
