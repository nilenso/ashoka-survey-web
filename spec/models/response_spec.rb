require 'spec_helper'

describe Response do
  it { should belong_to(:survey) }
  it { should have_db_column(:complete).with_options(default: false) }
  it { should allow_mass_assignment_of(:complete) }
  it { should have_many(:answers).dependent(:destroy) }
  it { should accept_nested_attributes_for(:answers) }
  it { should respond_to(:user_id) }
  it { should validate_presence_of(:survey_id)}
  it { should validate_presence_of(:organization_id)}
  it { should validate_presence_of(:user_id)}

  context "logic" do
  	it "returns five answers to display for a response" do
  	  response = FactoryGirl.create(:response, :survey => FactoryGirl.create(:survey),
       :organization_id => 1, :user_id => 1)
      6.times {response.answers << FactoryGirl.create(:answer)}  
      response.five_answers.should == response.answers.limit(5)
    end

    it "returns only the text typed answers" do
      response = FactoryGirl.create(:response, :survey => FactoryGirl.create(:survey),
       :organization_id => 1, :user_id => 1)
      question = FactoryGirl.create(:question, :type => "MultiChoiceQuestion")
      response.answers << FactoryGirl.create(:answer, :question => question)
      response.five_answers.should be_empty
      3.times {response.answers << FactoryGirl.create(:answer)}  
      response.five_answers.should_not be_empty
      response.five_answers.each { |i| i.should be_text_type }
    end 
  end
end
