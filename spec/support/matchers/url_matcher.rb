require 'uri'

RSpec::Matchers.define :be_a_url do
  match do |actual|
    actual =~ URI::regexp
  end
end
