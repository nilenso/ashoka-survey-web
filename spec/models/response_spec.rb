require 'spec_helper'

describe Response do
  it { should belong_to(:survey) }
  it { should have_db_column(:status).with_options(default: 'incomplete') }
  it { should have_many(:answers).dependent(:destroy) }
  it { should accept_nested_attributes_for(:answers) }
  it { should respond_to(:user_id) }
  it { should validate_presence_of(:survey_id)}
  it { should validate_presence_of(:organization_id)}
  it { should validate_presence_of(:user_id)}
  it { should allow_mass_assignment_of(:survey_id) }


  it "fetches the answers for the identifier questions" do
    response = FactoryGirl.create(:response, :survey => FactoryGirl.create(:survey), :organization_id => 1, :user_id => 1)
    identifier_question = FactoryGirl.create :question, :identifier => true
    normal_question = FactoryGirl.create :question, :identifier => false
    response.answers << FactoryGirl.create(:answer, :question_id => identifier_question.id,  :response_id => response.id) 
    response.answers << FactoryGirl.create(:answer, :question_id => normal_question.id,  :response_id => response.id) 
    response.answers_for_identifier_questions.should == identifier_question.answers
  end

  context "when marking a response incomplete" do
    it "marks the response incomplete" do
      survey = FactoryGirl.create(:survey)
      response = FactoryGirl.create(:response, :survey => survey, :organization_id => 1, :user_id => 1)
      response.incomplete
      response.reload.should_not be_complete
      response.complete
      response.reload.should be_complete
    end

    it "returns whether a response is complete or not" do
     survey = FactoryGirl.create(:survey)
     response = FactoryGirl.create(:response, :survey => survey, :organization_id => 1, :user_id => 1)
     response.validating
     response.reload.should be_validating 
    end
  end

  context "#set" do
    it "sets the survey_id, user_id and organization_id" do
      survey = FactoryGirl.create(:survey)
      response = FactoryGirl.build(:response)
      response.set(survey.id, 5, 6)
      response.survey_id.should == survey.id
      response.user_id.should == 5
      response.organization_id.should == 6
    end
  end
end
