require 'spec_helper'

describe DeepSurveySerializer do
  subject { DeepSurveySerializer.new(FactoryGirl.create(:survey)) }

  it { should have_json_key :name }
  it { should have_json_key :published_on }
  it { should have_json_key :id }
  it { should have_json_key :description }
  it { should have_json_key :expiry_date }
end