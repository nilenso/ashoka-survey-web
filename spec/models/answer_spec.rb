require 'spec_helper'

describe Answer do
  it { should respond_to(:content) }
  it { should belong_to(:question) }
  it { should belong_to(:response) }
  it { should have_many(:choices).dependent(:destroy) }
  it { should allow_mass_assignment_of(:updated_at) }

  context "validations" do
    context "for mandatory questions" do
      it "does not save if a mandatory question is not answered for a complete response" do
        question = FactoryGirl.create(:question, :mandatory => true)
        answer = FactoryGirl.create(:answer, :question_id => question.id)
        question.answers << answer

        answer.content = ''
        answer.should_not be_valid
      end

      it "adds errors to the content field for a non photo type question" do
        question = FactoryGirl.create(:question, :mandatory => true)
        answer = FactoryGirl.create(:answer, :question_id => question.id)
        question.answers << answer

        answer.content = ''
        answer.save
        answer.errors.to_hash[:content].should_not be_empty
      end

      it "adds errors to the photo field for non photo type question" do
        question = FactoryGirl.create(:question, :mandatory => true, :type => "PhotoQuestion")
        answer = FactoryGirl.create(:answer, :question_id => question.id)
        question.answers << answer

        answer.content = ''
        answer.save
        answer.errors.to_hash[:photo].should_not be_empty
      end
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

    context "ordering" do
      it "fetches answers in the ascending order of their questions' order numbers" do
        question_1 = FactoryGirl.create(:question, :order_number => 1)
        question_2 = FactoryGirl.create(:question, :order_number => 2)
        answer_2 = FactoryGirl.create(:answer, :question_id => question_2.id)
        answer_1 = FactoryGirl.create(:answer, :question_id => question_1.id)
        Answer.all.should == [answer_1, answer_2]
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

      it "doesn't create duplicate choices for an answer" do
        question = FactoryGirl.create(:question, :type => 'MultiChoiceQuestion')
        options = FactoryGirl.create_list(:option, 3, :question_id => question.id)
        option_ids = options.map(&:id)
        answer = FactoryGirl.create(:answer, :question_id => question.id, :option_ids => option_ids)
        answer.option_ids = [options.first.id]
        answer.choices.map(&:option_id).should =~ [options.first.id]
      end

      it "doesn't error out if no IDs are passed in" do
        answer = FactoryGirl.create(:answer)
        expect { answer.option_ids = nil }.to_not raise_error
      end

      it "doesn't change the answer content" do
        choices = [FactoryGirl.create(:option).id]
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
      it { should respond_to(:photo) }
      it "should have a maximum file size as in question's max length" do
        question = FactoryGirl.create(:question, :max_length => 2, :type => "PhotoQuestion")
        answer = FactoryGirl.build(:answer_with_image, :question => question)
        answer.photo.stub(:size).and_return(3.megabytes)
        answer.should_not be_valid
      end
    end

    it "Ensures that it is the only answer for a question within the response" do
      response = FactoryGirl.create(:response, :organization_id => 1, :user_id => 2, :survey_id => 3)
      question = RadioQuestion.create( :type => "RadioQuestion", :content => "hollo!")
      answer_1 = FactoryGirl.create(:answer, :question_id => question.id, :response_id => response.id)
      answer_2 = FactoryGirl.build(:answer, :question_id => question.id, :response_id => response.id)
      answer_2.should_not be_valid
    end

    context "when checking if the answer is blank" do
      it "checks for an empty answer to a multi-choice question" do
        question = FactoryGirl.create :question, :type => "MultiChoiceQuestion"
        answer = FactoryGirl.create(:answer, :content => '', :question_id => question.id)
        answer.should have_not_been_answered
      end

      it "checks for an empty answer to all other question types" do
        question = FactoryGirl.create :question, :type => "SingleLineQuestion"
        answer = FactoryGirl.create(:answer, :content => nil, :question_id => question.id)
        answer.should have_not_been_answered
      end
    end

    context "when checking if the answer is not blank" do
      it "checks for an answer to a multi-choice question" do
        question = FactoryGirl.create :question, :type => "MultiChoiceQuestion"
        answer = FactoryGirl.create(:answer, :content => '', :question_id => question.id)
        answer.choices << FactoryGirl.create(:choice)
        answer.should have_been_answered
      end

      it "checks for an answer to all other question types" do
        question = FactoryGirl.create :question, :type => "SingleLineQuestion"
        answer = FactoryGirl.create(:answer, :content => "FooBar", :question_id => question.id)
        answer.should have_been_answered
      end
    end
  end

  context "logic" do
    it "returns the comma separated options list as content for a multi choice answer" do
      question = FactoryGirl.create :question, :type => 'MultiChoiceQuestion'
      answer = FactoryGirl.create :answer_with_choices, :question => question
      answer.content.should == answer.choices.map(&:content).join(", ")
    end

    context "#content_for_excel" do
      it "returns a comma-separated list of choices for a MultiChoiceQuestion" do
        question = FactoryGirl.create :question, :type => 'MultiChoiceQuestion'
        answer = FactoryGirl.create :answer_with_choices, :question => question
        answer.content_for_excel.should == answer.choices.map(&:content).join(', ')
      end

      it "returns the `image_url` for a PhotoQuestion" do
        question = FactoryGirl.create :question, :type => 'PhotoQuestion'
        answer = FactoryGirl.create :answer_with_image, :question => question
        answer.content_for_excel('http://localhost:3000').should =~ /.*localhost.*3000.*\w*/
      end

      it "returns the value of the `content` column for all other types" do
        question = FactoryGirl.create :question, :type => 'SingleLineQuestion'
        answer = FactoryGirl.create :answer_with_choices, :question => question, :content => "xyz"
        answer.content_for_excel.should == "xyz"
      end

    end

    it "clears the content of the answer" do
      answer = FactoryGirl.create(:answer)
      answer.clear_content
      answer.reload.content.should be_blank 
    end
  end

  it "returns content of its question" do
    text_question = FactoryGirl.create(:question, :type => "SingleLineQuestion")
    text_answer = FactoryGirl.create(:answer, :question => text_question)
    text_answer.question_content.should == text_question.content
  end

  context "for images" do
    it "checks whether the answer is an image" do
      question = FactoryGirl.create :question, :type => 'PhotoQuestion'
      answer = FactoryGirl.create :answer_with_image, :question => question
      answer.should be_image
    end

    context "when encoding in base64" do
      it "returns the cached image if the remote image is still uploading" do
        question = FactoryGirl.create :question
        answer = FactoryGirl.create :answer, :question => question
        answer.photo.stub(:root).and_return(Rails.root)
        answer.photo.stub(:cache_dir).and_return("spec/fixtures/images")
        answer.photo_tmp = 'sample.jpg'
        answer.photo_in_base64.should == Base64.encode64(File.read('spec/fixtures/images/sample.jpg'))
      end

      it "returns the remote image if it's done uploading" do
        question = FactoryGirl.create :question
        answer = FactoryGirl.create :answer_with_image, :question => question
        answer.photo_in_base64.should == Base64.encode64(File.read(answer.photo.thumb.path))
      end
    end

    context "when getting the URL" do
      it "returns the relative URL to the cached (local) image if the S3 version hasn't uploaded" do
        question = FactoryGirl.create :question
        answer = FactoryGirl.create :answer, :question => question
        answer.photo.stub(:root).and_return(Rails.root)
        answer.photo.stub(:cache_dir).and_return("spec/fixtures/images")
        answer.photo_tmp = 'sample.jpg'
        answer.photo_url.should == '/spec/fixtures/images/sample.jpg'
      end

      it "returns the URL to the S3 version if it's uploaded" do
        question = FactoryGirl.create :question
        answer = FactoryGirl.create :answer_with_image, :question => question
        answer.photo_tmp = nil
        answer.photo_url.should == answer.photo.url
      end

      it "takes a format (medium or thumb) which it returns only for the S3 version" do
        question = FactoryGirl.create :question
        answer = FactoryGirl.create :answer_with_image, :question => question
        answer.photo_tmp = nil
        answer.photo_url(:thumb).should == answer.photo.thumb.url
      end

      it "returns empty if the question doesn't have an image" do
        question = FactoryGirl.create :question
        answer = FactoryGirl.create :answer, :question => question
        answer.photo_url.should be_empty
      end
    end
  end

end
