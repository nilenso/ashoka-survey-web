require 'spec_helper'

describe DropDownQuestion do
  it_behaves_like "a question"
  it_behaves_like "a question with options", DropDownQuestion
end
