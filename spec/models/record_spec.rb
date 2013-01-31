require 'spec_helper'

describe Record do
  it { should belong_to :category }
  it { should have_many(:answers).dependent(:destroy) }
  it { should allow_mass_assignment_of(:category_id) }
  it { should allow_mass_assignment_of(:response_id) }
end
