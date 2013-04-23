require 'spec_helper'

describe DeepQuestionSerializer do
  subject { DeepQuestionSerializer.new(FactoryGirl.create(:question)) }

  it { should have_json_key :id}  
  it { should have_json_key :identifier}  
  it { should have_json_key :parent_id}  
  it { should have_json_key :min_value}  
  it { should have_json_key :max_value}  
  it { should have_json_key :type}  
  it { should have_json_key :content}  
  it { should have_json_key :survey_id}  
  it { should have_json_key :max_length}  
  it { should have_json_key :mandatory}  
  it { should have_json_key :image_url}  
  it { should have_json_key :order_number}  
  it { should have_json_key :category_id}
end