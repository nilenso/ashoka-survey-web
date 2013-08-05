require 'spec_helper'

shared_examples "a question with options" do |question_klass|

  let(:factory_name) { question_klass.to_s.underscore.to_sym }

  context "reports" do
    it "counts all its answers grouped by the option's content" do
      question = FactoryGirl.create(factory_name, :finalized)
      first_option = FactoryGirl.create(:option, :question => question, :content => "Foo")
      second_option = FactoryGirl.create(:option, :question => question, :content => "Bar")
      5.times { FactoryGirl.create(:answer_with_complete_response, :content => "Foo", :question => question) }
      3.times { FactoryGirl.create(:answer_with_complete_response, :content => "Bar", :question => question) }
      question.report_data.should include ["Foo", 5]
      question.report_data.should include ["Bar", 3]
    end

    it "returns an empty array if no answers belonging to a completed response exist for the question" do
      survey = FactoryGirl.create(:survey, :finalized)
      question = FactoryGirl.create(:radio_question, :with_options)
      response = FactoryGirl.create(:response, :survey => survey, :organization_id => 1, :user_id => 2)
      FactoryGirl.create(:answer, :content => question.options.first.content, :response_id => response.id)
      question.report_data.should be_empty
    end
  end
end
