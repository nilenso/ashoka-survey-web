require 'spec_helper'

describe Answer do
  it { should respond_to(:content) }
  it { should belong_to(:question) }
  context "validations" do
    it "does not save if a mandatory question is not answered" do
      question = FactoryGirl.create(:question, :mandatory => true)
      answer = FactoryGirl.create(:answer, :question_id => question.id)
      question.answers << answer

      answer.content = ''
      answer.should_not be_valid
    end
  end  
end
