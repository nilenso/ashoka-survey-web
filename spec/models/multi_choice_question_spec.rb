require 'spec_helper'

describe MultiChoiceQuestion do
  it_behaves_like "a question"

  context "reports" do
    it "returns the number of answers grouped by option content" do
      question = FactoryGirl.create(:multi_choice_question, :finalized, :with_options)
      5.times do
        response = FactoryGirl.create(:response, :clean, :complete)
        answer = FactoryGirl.create(:answer, :response => response, :question => question)
        answer.choices << FactoryGirl.create(:choice, :option => question.options.first)
      end
      question.reload.report_data.should include [question.options.first.content, 5]
    end

    it "returns an empty array if no answers are present" do
      question = FactoryGirl.create(:multi_choice_question, :finalized, :with_options)
      question.report_data.should == []
    end
  end
end
