require 'spec_helper'

describe DeepOptionSerializer do
  subject { DeepOptionSerializer.new(FactoryGirl.create(:option)) }

  it { should have_json_key :order_number }
  it { should have_json_key :id }
  it { should have_json_key :content }
  it { should have_json_key :question_id }
end