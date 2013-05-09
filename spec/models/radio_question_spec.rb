require 'spec_helper'

describe RadioQuestion do
  it_behaves_like "a question"
  it_behaves_like "a question with options", RadioQuestion
end
