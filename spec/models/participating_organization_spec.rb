require 'spec_helper'

describe ParticipatingOrganization do
  it { should respond_to :survey_id }
  it { should respond_to :organization_id }
  it { should belong_to :survey }
end
