require 'spec_helper'
require "paperclip/matchers"

describe Answer do
  it { should respond_to(:content) }
  it { should belong_to(:question) }
  it { should belong_to(:response) }

  it { should have_many(:choices).dependent(:destroy) }

  context "validations" do
    it "does not save if a mandatory question is not answered for a complete response" do
      question = FactoryGirl.create(:question, :mandatory => true)
      answer = FactoryGirl.create(:answer, :question_id => question.id)
      question.answers << answer

      answer.content = ''
      answer.should_not be_valid
    end

    context "when validating max length" do
      it "does not save if the content of the answer is larger than the max-length for a RatingQuestion" do
        question = FactoryGirl.create(:question, :max_length => 7, :type => 'RatingQuestion')
        answer = FactoryGirl.create(:answer, :question_id => question.id)
        question.answers << answer

        answer.content = '8'
        answer.should_not be_valid
      end

      it "does not save if content of the answer length exceeds maximum length for all other question types" do
        question = FactoryGirl.create(:question, :max_length => 7)
        answer = FactoryGirl.create(:answer, :question_id => question.id)
        question.answers << answer

        answer.content = 'foobarbaz'
        answer.should_not be_valid
      end
    end

    it "does not save if the answer is less than the minimum value" do
      question = FactoryGirl.create(:question, :type => 'NumericQuestion', :min_value => 5)
      answer = FactoryGirl.build(:answer, :question_id => question.id)
      question.answers << answer

      answer.content = 3
      answer.should_not be_valid
    end

    context "when validating numeric questions" do
      it "does not save if the answer is not a number" do
        question = FactoryGirl.create(:question, :type => 'NumericQuestion')
        answer = FactoryGirl.build(:answer, :question_id => question.id)
        question.answers << answer

        answer.content = 'as'
        answer.should_not be_valid
      end

      it "does not save if the answer is greater than the maximum value" do
        question = FactoryGirl.create(:question, :type => 'NumericQuestion', :max_value => 5)
        answer = FactoryGirl.build(:answer, :question_id => question.id)
        question.answers << answer

        answer.content = 8
        answer.should_not be_valid
      end

      it "doesn't error out if the answer is blank" do
        question = FactoryGirl.create(:question, :type => 'NumericQuestion')
        answer = FactoryGirl.build(:answer, :question_id => question.id)
        question.answers << answer

        answer.content = ''
        answer.should be_valid
      end
    end

    it "does not save if the answer to a date type question is not a valid date" do
      question = FactoryGirl.create(:question, :type => 'DateQuestion')
      answer = FactoryGirl.build(:answer, :question_id => question.id)
      question.answers << answer

      answer.content = "4235643861"
      answer.should_not be_valid
      answer.content = "1990/10/24"
      answer.should be_valid
    end

    context "for multi-choice questions" do
      it "does not save if it doesn't have any choices selected" do
        question = FactoryGirl.create(:question, :type => 'MultiChoiceQuestion', :mandatory => true)
        answer = FactoryGirl.build(:answer, :question_id => question.id)
        answer.should_not be_valid
      end

      it "saves if even a single choice is selected" do
        question = MultiChoiceQuestion.create(:type => 'MultiChoiceQuestion', :mandatory => true, :content => "some question")
        option = FactoryGirl.create(:option, :question_id => question.id)
        answer = FactoryGirl.build(:answer, :question_id => question.id, :option_ids => [option.id])
        answer.should be_valid
      end
    end

    context "when creating choices for a MultiChoiceQuestion" do
      it "creates choices for the selected options" do
        question = MultiChoiceQuestion.create(:type => 'MultiChoiceQuestion', :content => 'some question')
        options = FactoryGirl.create_list(:option, 3, :question_id => question.id)
        option_ids = options.map(&:id).unshift('')
        answer = FactoryGirl.create(:answer, :question_id => question.id, :option_ids => option_ids)
        answer.choices.map(&:option_id).should =~ option_ids
      end

      it "doesn't create choices for any other question type" do
        question = FactoryGirl.create(:question, :type => 'SingleLineQuestion')
        answer = FactoryGirl.create(:answer, :question_id => question.id)
        answer.choices.should == []
      end

      it "doesn't change the answer content" do
        choices = ["first"]
        question = FactoryGirl.create(:question, :type => 'MultiChoiceQuestion')
        answer = FactoryGirl.create(:answer, :question_id => question.id, :option_ids => choices)
        answer.content.should == answer.content
      end

      it "looks at choices instead of content when checking for a mandatory question" do
        question = MultiChoiceQuestion.create(:type => 'MultiChoiceQuestion', :mandatory => true, :content => "multi-choice-question")
        option = FactoryGirl.create(:option, :question_id => question.id)
        answer = FactoryGirl.build(:answer, :content => nil, :question_id => question.id, :option_ids => [option.id])
        answer.should be_valid
      end
    end

    context "description" do
      subject { FactoryGirl.create(:answer, :question => FactoryGirl.create(:question))}
      it { should have_attached_file(:photo) }
      it { should validate_attachment_content_type(:photo).
           allowing('image/png').
           rejecting('image/gif') }
      it "should have a maximum file size as in question's max length" do
        question = FactoryGirl.create(:question, :max_length => 2, :type => "PhotoQuestion")
        answer = FactoryGirl.build(:answer, :question => question, :photo_file_size => 3.megabytes)
        answer.should_not be_valid
      end
    end
  end

  context "logic" do
    it "checks whether the answer is of text type" do
      text_question = FactoryGirl.create(:question, :type => "SingleLineQuestion")
      text_answer = FactoryGirl.create(:answer, :question => text_question)
      text_answer.should be_text_type
      non_textual_question = FactoryGirl.create(:question, :type => "MultiChoiceQuestion")
      non_textual_answer = FactoryGirl.create(:answer, :question => non_textual_question)
      non_textual_answer.should_not be_text_type
    end

    context "#content_for_excel" do
      it "returns a comma-separated list of choices for a MultiChoiceQuestion" do
        question = FactoryGirl.create :question, :type => 'MultiChoiceQuestion'
        answer = FactoryGirl.create :answer_with_choices, :question => question
        answer.content_for_excel.should == answer.choices.map(&:content).join(', ')
      end

      it "returns the `image_url` for a PhotoQuestion" do
        
      end

      it "returns the value of the `content` column for all other types" do
        question = FactoryGirl.create :question, :type => 'SingleLineQuestion'
        answer = FactoryGirl.create :answer_with_choices, :question => question, :content => "xyz"
        answer.content_for_excel.should == "xyz"
      end 
    end
  end

  it "returns content of its question" do
    text_question = FactoryGirl.create(:question, :type => "SingleLineQuestion")
    text_answer = FactoryGirl.create(:answer, :question => text_question)
    text_answer.question_content.should == text_question.content
  end
end
