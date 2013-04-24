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

  it "should include its options" do
    question_with_options = RadioQuestion.find(FactoryGirl.create(:question_with_options).id)  
    serializer = DeepQuestionSerializer.new(question_with_options)
    json = serializer.as_json    
    json[:options].map { |option| option[:id] }.should =~ question_with_options.options.map(&:id)
  end

  it "doesn't include options if not a QuestionWithOptions" do
    question = SingleLineQuestion.find(FactoryGirl.create(:question, :type => "SingleLineQuestion").id)
    serializer = DeepQuestionSerializer.new(question)
    json = serializer.as_json
    json.should_not have_key 'options'
  end
end