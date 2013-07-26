require 'spec_helper'

describe Answer do
  context "validations" do
    context "for mandatory questions" do
      let(:complete_response) { FactoryGirl.create(:response, :complete) }

      it "does not save if a mandatory question is not answered for a complete response" do
        question = FactoryGirl.create(:question, :finalized, :mandatory => true)
        answer = FactoryGirl.create(:answer, :question => question, :response => complete_response)
        answer.content = ''
        answer.should_not be_valid
      end

      it "adds errors to the content field for a non photo type question" do
        question = FactoryGirl.create(:question, :finalized, :mandatory => true)
        answer = FactoryGirl.create(:answer, :question => question, :response => complete_response)

        answer.content = ''
        answer.save
        answer.errors.to_hash[:content].should_not be_empty
      end

      it "adds errors to the photo field for photo question" do
        question = FactoryGirl.create(:photo_question, :finalized, :mandatory)
        answer = FactoryGirl.build(:answer, :question => question, :response => complete_response)
        answer.content = ''
        answer.save
        answer.errors.to_hash[:photo].should_not be_empty
      end
    end

    context "when updating the photo_file_size" do
      before(:each) do
        ImageUploader.enable_processing = true
      end

      after(:each) do
        ImageUploader.enable_processing = false
      end

      it "sets the total size of all three versions of the image" do
        photo = fixture_file_upload('/images/sample.jpg')
        answer = FactoryGirl.create(:answer, :photo => photo)
        answer.update_photo_size!
        total_size = answer.photo.file.size + answer.photo.thumb.file.size + answer.photo.medium.file.size
        answer.photo_file_size.should == total_size
      end

      it "sets the size to nil if the image is removed" do
        photo = fixture_file_upload('/images/sample.jpg')
        answer = FactoryGirl.create(:answer, :photo => photo)
        answer.remove_photo!
        answer.update_photo_size!
        answer.reload.photo_file_size.should be_nil
      end

      it "changes the size when the image is changed" do
        photo = fixture_file_upload('/images/sample.jpg')
        answer = FactoryGirl.create(:answer, :photo => photo)
        answer.photo = fixture_file_upload('/images/another.jpg')
        expect do
          answer.update_photo_size!
        end.to change { answer.photo_file_size }
      end
    end

    context "when validating max length" do
      it "does not save if the content of the answer is larger than the max-length for a RatingQuestion" do
        question = FactoryGirl.create(:rating_question, :finalized, :max_length => 7)
        answer = FactoryGirl.create(:answer, :question => question)
        answer.content = '8'
        answer.should_not be_valid
      end

      it "does not save if content of the answer length exceeds maximum length for all other question types" do
        question = FactoryGirl.create(:question, :finalized, :max_length => 7)
        answer = FactoryGirl.create(:answer, :question => question)
        answer.content = 'foobarbaz'
        answer.should_not be_valid
      end

      it "does not run this validation if the answer has no content" do
        question = FactoryGirl.create(:question, :finalized, :max_length => 7)
        expect do
          FactoryGirl.create(:answer, :content => nil, :question_id => question.id)
        end.not_to raise_error
      end
    end

    context "scopes" do
      it "fetches answers that belong to a complete response" do
        complete_response = FactoryGirl.create(:response, :status => 'complete')
        incomplete_response = FactoryGirl.create(:response, :status => 'incomplete')
        complete_answer = FactoryGirl.create(:answer, :response => complete_response)
        incomplete_answer = FactoryGirl.create(:answer, :response => incomplete_response)
        Answer.complete.should == [complete_answer]
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
        answer = FactoryGirl.build(:answer)
        answer.content = ''
        answer.should be_valid
      end
    end

    it "does not save if the answer to a date type question is not a valid date" do
      question = FactoryGirl.create(:date_question, :finalized)
      answer = FactoryGirl.build(:answer, :question_id => question.id)
      question.answers << answer
      answer.content = "4235643861"
      answer.should_not be_valid
      answer.content = "1990/10/24"
      answer.should be_valid
    end

    context "for multi-choice questions" do
      it "does not save if it doesn't have any choices selected" do
        question = FactoryGirl.create(:multi_choice_question, :mandatory)
        answer = FactoryGirl.build(:answer, :question_id => question.id)
        answer.should_not be_valid
      end

      it "saves if even a single choice is selected" do
        question = FactoryGirl.create(:multi_choice_question, :finalized, :mandatory, :content => "foo")
        option = FactoryGirl.create(:option, :question_id => question.id)
        answer = FactoryGirl.build(:answer, :question_id => question.id, :option_ids => [option.id])
        answer.should be_valid
      end
    end

    context "when creating choices for a MultiChoiceQuestion" do
      it "creates choices for the selected options" do
        question = FactoryGirl.create(:multi_choice_question, :finalized, :with_options)
        option_ids = question.options.map(&:id)
        answer = FactoryGirl.create(:answer, :question_id => question.id, :option_ids => option_ids)
        answer.choices.map(&:option_id).should =~ option_ids
      end

      it "doesn't create choices for any other question type" do
        answer = FactoryGirl.create(:answer)
        answer.choices.should == []
      end

      it "doesn't create duplicate choices for an answer" do
        question = FactoryGirl.create(:multi_choice_question, :finalized)
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
        question = FactoryGirl.create(:multi_choice_question, :finalized)
        answer = FactoryGirl.create(:answer, :question_id => question.id, :option_ids => choices)
        answer.content.should == answer.content
      end

      it "looks at choices instead of content when checking for a mandatory question" do
        question = FactoryGirl.create(:multi_choice_question, :finalized, :mandatory, :content => "foo")
        option = FactoryGirl.create(:option, :question_id => question.id)
        answer = FactoryGirl.build(:answer, :content => nil, :question_id => question.id, :option_ids => [option.id])
        answer.should be_valid
      end
    end

    context "description" do
      subject { FactoryGirl.create(:answer, :question => FactoryGirl.create(:question, :finalized))}
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
      question = FactoryGirl.create(:radio_question, :finalized)
      answer_1 = FactoryGirl.create(:answer, :question_id => question.id, :response_id => response.id)
      answer_2 = FactoryGirl.build(:answer, :question_id => question.id, :response_id => response.id)
      answer_2.should_not be_valid
    end

    context "when checking if the answer is blank" do
      it "checks for an empty answer to a multi-choice question" do
        question = FactoryGirl.create :multi_choice_question, :finalized
        answer = FactoryGirl.create(:answer, :content => '', :question => question)
        answer.should have_not_been_answered
      end

      it "checks for an empty answer to a photo question" do
        question = FactoryGirl.create :photo_question, :finalized
        answer = FactoryGirl.create(:answer, :content => '', :question_id => question.id, :photo => nil)
        answer.should have_not_been_answered
      end

      it "checks for an empty answer to all other question types" do
        question = FactoryGirl.create :question, :finalized
        answer = FactoryGirl.create(:answer, :content => nil, :question_id => question.id)
        answer.should have_not_been_answered
      end
    end

    context "when checking if the answer is not blank" do
      it "checks for an answer to a multi-choice question" do
        question = FactoryGirl.create :multi_choice_question, :finalized
        answer = FactoryGirl.create(:answer, :content => '', :question_id => question.id)
        answer.choices << FactoryGirl.create(:choice)
        answer.should have_been_answered
      end

      it "checks for an answer to a photo question" do
        photo = fixture_file_upload('/images/sample.jpg', 'text/jpeg')
        question = FactoryGirl.create :photo_question, :finalized
        answer = FactoryGirl.create(:answer, :content => '', :question_id => question.id, :photo => photo)
        answer.should have_been_answered
      end

      it "checks for an answer to all other question types" do
        question = FactoryGirl.create :question, :finalized
        answer = FactoryGirl.create(:answer, :content => "FooBar", :question_id => question.id)
        answer.should have_been_answered
      end
    end

    it "should not be valid when it's question is unfinalized" do
      question = FactoryGirl.create(:question, :finalized => false)
      answer = FactoryGirl.build(:answer, :question => question)
      answer.should_not be_valid
      answer.should have(1).error_on(:question_id)
    end
  end

  context "logic" do
    it "returns the comma separated options list as content for a multi choice answer" do
      answer = FactoryGirl.create :answer_with_choices
      answer.content.should == answer.choices.map(&:content).join(", ")
    end

    context "#content_for_excel" do
      it "returns a comma-separated list of choices for a MultiChoiceQuestion" do
        answer = FactoryGirl.create :answer_with_choices
        answer.content_for_excel.should == answer.choices.map(&:content).join(', ')
      end

      it "returns the `image_url` for a PhotoQuestion" do
        answer = FactoryGirl.create :answer_with_image
        answer.content_for_excel('http://localhost:3000').should =~ /.*localhost.*3000.*\w*/
      end

      it "returns the value of the `content` column for all other types" do
        question = FactoryGirl.create :question, :finalized, :type => 'SingleLineQuestion'
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
    text_question = FactoryGirl.create(:question, :finalized, :type => "SingleLineQuestion")
    text_answer = FactoryGirl.create(:answer, :question => text_question)
    text_answer.question_content.should == text_question.content
  end

  context "for images" do
    it "checks whether the answer is an image" do
      answer = FactoryGirl.create :answer_with_image
      answer.should be_image
    end

    context "when encoding in base64" do

      before(:each) do
        CarrierWave.configure do |config|
          config.enable_processing = true
        end
      end

      it "returns the cached image if the remote image is still uploading" do
        answer = FactoryGirl.create :answer
        answer.photo.stub(:root).and_return(Rails.root)
        answer.photo.stub(:cache_dir).and_return("spec/fixtures/images")
        answer.photo_tmp = 'sample.jpg'
        answer.photo_in_base64.should == Base64.encode64(File.read('spec/fixtures/images/sample.jpg'))
      end

      it "returns the remote image if it's done uploading" do
        answer = FactoryGirl.create :answer_with_image
        answer.photo_in_base64.should == Base64.encode64(File.read(answer.photo.path))
      end
    end

    context "when getting the URL" do
      it "returns the relative URL to the cached (local) image if the S3 version hasn't uploaded" do
        answer = FactoryGirl.create :answer
        answer.photo.stub(:root).and_return(Rails.root)
        answer.photo.stub(:cache_dir).and_return("spec/fixtures/images")
        answer.photo_tmp = 'sample.jpg'
        answer.photo_url.should == '/spec/fixtures/images/sample.jpg'
      end

      it "returns the URL to the S3 version if it's uploaded" do
        answer = FactoryGirl.create :answer_with_image
        answer.photo_tmp = nil
        answer.photo_url.should == answer.photo.url
      end

      it "takes a format (medium or thumb) which it returns only for the S3 version" do
        answer = FactoryGirl.create :answer_with_image
        answer.photo_tmp = nil
        answer.photo_url(:format => :thumb).should == answer.photo.thumb.url
      end

      it "returns empty if the question doesn't have an image" do
        answer = FactoryGirl.create :answer
        answer.photo_url.should be_empty
      end
    end
  end

end
