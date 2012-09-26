require 'spec_helper'

describe SurveyUser do
  it { should respond_to :survey_id }
  it { should respond_to :user_id }
  it {should belong_to :survey }
end
