require 'spec_helper'

describe Response do
  it { should belong_to(:survey) }
  it { should have_db_column(:status).with_options(default: 'incomplete') }
  it { should have_many(:answers).dependent(:destroy) }
  it { should accept_nested_attributes_for(:answers) }
  it { should respond_to(:user_id) }
  it { should respond_to(:latitude) }
  it { should respond_to(:longitude) }
  it { should respond_to(:ip_address) }
  it { should respond_to(:location) }
  it { should validate_presence_of(:survey_id)}
  it { should validate_presence_of(:organization_id)}
  it { should validate_presence_of(:user_id)}
  it { should allow_mass_assignment_of(:survey_id) }
  it { should allow_mass_assignment_of(:status) }
  it { should allow_mass_assignment_of(:updated_at) }
  it { should allow_mass_assignment_of(:latitude) }
  it { should allow_mass_assignment_of(:longitude) }
  it { should allow_mass_assignment_of(:ip_address) }


  it "fetches the answers for the identifier questions" do
    response = FactoryGirl.create(:response, :survey => FactoryGirl.create(:survey), :organization_id => 1, :user_id => 1)
    identifier_question = FactoryGirl.create :question, :identifier => true
    normal_question = FactoryGirl.create :question, :identifier => false
    response.answers << FactoryGirl.create(:answer, :question_id => identifier_question.id,  :response_id => response.id)
    response.answers << FactoryGirl.create(:answer, :question_id => normal_question.id,  :response_id => response.id)
    response.answers_for_identifier_questions.should == identifier_question.answers
  end

  it "gives you first five answers if there are no identfier questions " do
    response = FactoryGirl.create(:response, :survey => FactoryGirl.create(:survey), :organization_id => 1, :user_id => 1)
    question = FactoryGirl.create :question, :identifier => false
    response.answers << FactoryGirl.create(:answer, :question_id => question.id, :response_id => response.id)
    response.answers_for_identifier_questions.should == question.answers
  end

  it "merges the response status based on updated_at" do 
    response = FactoryGirl.create :response, :organization_id => 1, :user_id => 1, :status => 'complete'
    response.merge_status({ :status => 'incomplete', :updated_at => 5.days.ago.to_s })
    response.should be_complete
    response.merge_status({ :status => 'incomplete', :updated_at => 5.days.from_now.to_s })
    response.should be_incomplete
  end
  
  it "doesn't require a user_id and organization_id if it's survey is public" do
    survey = FactoryGirl.create :survey, :public => true
    response = Response.new(:survey => survey)
    response.should be_valid
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

    it "returns whether a response is incomplete or not" do
     survey = FactoryGirl.create(:survey)
     response = FactoryGirl.create(:response, :survey => survey, :organization_id => 1, :user_id => 1)
     response.incomplete
     response.reload.should be_incomplete
    end
  end

  context "#set" do
    it "sets the survey_id, user_id, organization_id and session_token" do
      survey = FactoryGirl.create(:survey)
      response = FactoryGirl.build(:response)
      response.set(survey.id, 5, 6, "foo")
      response.survey_id.should == survey.id
      response.user_id.should == 5
      response.organization_id.should == 6
      response.session_token.should == "foo"
    end
  end

  it "gets the questions that it contains answers for" do
    survey = FactoryGirl.create(:survey)
    response = FactoryGirl.build(:response, :survey_id => survey.id)
    response.questions.should == survey.questions
  end
  
  it "gets the public status of its survey" do
    survey = FactoryGirl.create(:survey, :public => true)
    response = FactoryGirl.build(:response, :survey_id => survey.id)
    response.survey_public?.should be_true
  end

  it "provides the filename for the excel file" do
    survey = FactoryGirl.create(:survey)
    response = FactoryGirl.build(:response, :survey_id => survey.id)
    response.filename_for_excel.should =~ /#{survey.name}/
    response.filename_for_excel.should include Time.now.to_s
    response.filename_for_excel.should =~ /.*xlsx$/
  end

  context "when updating answers" do
    it "selects only the new answers to update" do
      survey = FactoryGirl.create(:survey)
      response = FactoryGirl.create(:response, :survey => survey, :organization_id => 1, :user_id => 1)
      question_1 = FactoryGirl.create(:question, :survey_id => survey.id)
      question_2 = FactoryGirl.create(:question, :survey_id => survey.id)
      answer_1 = FactoryGirl.create(:answer, :question_id => question_1.id, :updated_at => Time.now, :content => "older", :response_id => response.id)
      answer_2 = FactoryGirl.create(:answer, :question_id => question_2.id, :updated_at => 5.hours.from_now, :content => "newer", :response_id => response.id)
      answers_attributes = { '0' => {"question_id" => question_1.id, "updated_at" => 5.hours.from_now.to_s, "id" => answer_1.id, "content" => "newer"},
                             '1' => {"question_id" => question_2.id, "updated_at" => Time.now.to_s, "id" => answer_2.id, "content" => "older"}}
      selected_answers = response.select_new_answers(answers_attributes)
      selected_answers.keys.should == ['0']
    end
  end

  context "#to_json_with_answers_and_choices" do
    it "renders the answers" do
      response = (FactoryGirl.create :response_with_answers).reload
      response_json = JSON.parse(response.to_json_with_answers_and_choices)
      response_json.should have_key('answers')
      response_json['answers'].size.should == response.answers.size
    end

    it "renders the answers' image as base64 as well" do
      response = (FactoryGirl.create :response).reload
      photo = Rack::Test::UploadedFile.new('spec/fixtures/images/sample.jpg')
      photo.content_type = 'image/jpeg'
      photo_answer = FactoryGirl.create(:answer, :photo => photo, :question => FactoryGirl.create(:question, :type => 'PhotoQuestion'))
      response.answers << photo_answer
      response_json = JSON.parse(response.to_json_with_answers_and_choices)
      response_json['answers'][0].should have_key('photo_in_base64')
      response_json['answers'][0]['photo_in_base64'].should == photo_answer.photo_in_base64
    end

    it "renders the answers' choices if any" do
      response = (FactoryGirl.create :response).reload
      response.answers << FactoryGirl.create(:answer_with_choices)
      response_json = JSON.parse(response.to_json_with_answers_and_choices)
      response_json['answers'][0].should have_key('choices')
      response_json['answers'][0]['choices'].size.should == response.answers[0].choices.size
    end
  end
end