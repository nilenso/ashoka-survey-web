require 'spec_helper'

describe DeepSurveySerializer do
  subject { DeepSurveySerializer.new(FactoryGirl.create(:survey)) }

  it { should have_json_key :name }
  it { should have_json_key :published_on }
  it { should have_json_key :id }
  it { should have_json_key :description }
  it { should have_json_key :expiry_date }

  context "when serializing the associated elements" do
    it "includes only the finalized questions" do
      file = fixture_file_upload('/images/sample.jpg')
      Question.any_instance.stub_chain(:image, :thumb, :file).and_return(file)
      survey = FactoryGirl.create(:survey)
      finalized_question = FactoryGirl.create(:question, :finalized, :survey => survey)
      non_finalized_question = FactoryGirl.create(:question, :survey => survey)
      serializer = DeepSurveySerializer.new(survey)
      json = serializer.as_json
      json[:questions].map { |q| q[:id] }.should == [finalized_question.id]
    end

    it "includes only the finalized categories" do
      survey = FactoryGirl.create(:survey)
      finalized_category = FactoryGirl.create(:category, :finalized, :survey => survey)
      non_finalized_category = FactoryGirl.create(:category, :survey => survey)
      serializer = DeepSurveySerializer.new(survey)
      json = serializer.as_json
      json[:categories].map { |q| q[:id] }.should == [finalized_category.id]
    end
  end
end
