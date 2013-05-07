require 'spec_helper'

describe Record do
  it { should validate_presence_of(:category_id) }
end
