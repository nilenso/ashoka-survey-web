require 'spec_helper'

describe DeepCategorySerializer do
  subject { DeepCategorySerializer.new(FactoryGirl.create(:category)) }

  it { should have_json_key :id}    
  it { should have_json_key :parent_id}  
  it { should have_json_key :type}  
  it { should have_json_key :content}  
  it { should have_json_key :survey_id}   
  it { should have_json_key :order_number}  
  it { should have_json_key :category_id}
end