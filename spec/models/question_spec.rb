require 'spec_helper'
include ActionDispatch::TestProcess

describe Question do
  context "scopes" do
    context "when finding non-private questions" do
      it "gets questions which have the private flag set to false" do
        question = FactoryGirl.create(:question, :private => false)
        Question.not_private.should == [question]
      end

      it "gets questions which have the private flag set to nil" do
        question = FactoryGirl.create(:question, :private => nil)
        Question.not_private.should == [question]
      end

      it "filters out questions which are private" do
        private_question = FactoryGirl.create(:question, :private => true)
        Question.not_private.should_not include private_question
      end
    end

    it "gets questions which are finalized" do
      finalized_question = FactoryGirl.create(:question, :finalized)
      non_finalized_question = FactoryGirl.create(:question)
      Question.finalized.should == [finalized_question]
    end
  end

  context "callbacks" do
    context "when setting the photo_file_size" do
      before(:each) do
        ImageUploader.enable_processing = true
      end

      after(:each) do
        ImageUploader.enable_processing = false
      end

      it "sets the total size of all three versions of the image" do
        image = fixture_file_upload('/images/sample.jpg')
        question = FactoryGirl.create(:question, :image => image)
        total_size = question.image.file.size + question.image.thumb.file.size + question.image.medium.file.size
        question.photo_file_size.should == total_size
      end

      it "sets the size to nil if the image is removed" do
        image = fixture_file_upload('/images/sample.jpg')
        question = FactoryGirl.create(:question, :image => image)
        question.remove_image!
        question.save
        question.reload.photo_file_size.should be_nil
      end

      it "changes the size when the image is changed" do
        image = fixture_file_upload('/images/sample.jpg')
        question = FactoryGirl.create(:question, :image => image)
        expect do
          question.image = fixture_file_upload('/images/another.jpg')
          question.save
        end.to change { question.photo_file_size }
      end
    end

        context "when destroying" do
      context "if the survey is marked for deletion" do
        let(:survey) { FactoryGirl.create(:survey, :marked_for_deletion) }

        it "destroys if it is finalized" do
          question = FactoryGirl.create(:question, :finalized, :content => "FOO", :survey => survey)
          expect { question.destroy }.to change { Question.count }.by(-1)
        end

        it "destroys if it is not finalized" do
          question = FactoryGirl.create(:question, :content => "FOO", :survey => survey)
          expect { question.destroy }.to change { Question.count }.by(-1)
        end
      end

      context "if the survey is not marked for deletion" do
        let(:survey) { FactoryGirl.create(:survey, :marked_for_deletion => false) }

        it "doesn't destroy if it is finalized" do
          question = FactoryGirl.create(:question, :finalized, :content => "FOO", :survey => survey)
          expect { question.destroy }.not_to change { Question.count }
        end

        it "destroys if it is not finalized" do
          question = FactoryGirl.create(:question, :finalized => false, :content => "FOO", :survey => survey)
          expect { question.destroy }.to change { Question.count }
        end
      end
    end
  end

  context "validation" do
    context "for a finalized survey" do
      it "allows creating a non-mandatory question" do
        survey = FactoryGirl.create(:survey, :finalized)
        question = FactoryGirl.build(:question, :survey => survey)
        question.should be_valid
      end

      it "doesn't allow creation of a mandatory question" do
        survey = FactoryGirl.create(:survey, :finalized)
        question = FactoryGirl.build(:question, :mandatory, :survey => survey)
        question.should_not be_valid
        question.should have(1).error_on(:survey_id)
      end

      it "doesn't allow making an existing question mandatory" do
        survey = FactoryGirl.create(:survey, :finalized)
        question = FactoryGirl.create(:question, :survey => survey)
        question.mandatory = true
        question.should_not be_valid
      end

      it "allows updation of an existing mandatory question" do
        survey = FactoryGirl.create(:survey)
        question = FactoryGirl.create(:question, :mandatory, :survey => survey)
        survey.finalize
        question.content = "Foo"
        question.should be_valid
      end
    end

    context "for a non-finalized survey" do
      it "allows creation of a mandatory question" do
        survey = FactoryGirl.create(:survey, :finalized => false)
        question = FactoryGirl.build(:question, :mandatory, :survey => survey)
        question.should be_valid
      end

      it "allows making an existing question mandatory" do
        survey = FactoryGirl.create(:survey, :finalized => false)
        question = FactoryGirl.create(:question, :survey => survey)
        question.mandatory = true
        question.should be_valid
      end
    end


    context "when updating a finalized question" do
      it "allows updating if the content has changed" do
        question = FactoryGirl.create(:question, :finalized, :content => "FOO")
        question.content = "BAR"
        question.should be_valid
      end

      it "allows updating if the order_number has changed" do
        question = FactoryGirl.create(:question, :finalized, :order_number => 1)
        question.order_number = 2
        question.should be_valid
      end

      it "allows updating if the private field has changed" do
        question = FactoryGirl.create(:question, :finalized, :private => false)
        question.private = true
        question.should be_valid
      end

      it "allows updating if the identifier field has changed" do
        question = FactoryGirl.create(:question, :finalized, :identifier => false)
        question.identifier = true
        question.should be_valid
      end

      it "allows updating if the image field has changed" do
        question = FactoryGirl.create(:question, :finalized, :image => nil)
        question.image = "some_image"
        question.should be_valid
      end

      it "does not allow updation of any other field" do
        question = FactoryGirl.create(:question, :finalized, :max_length => 1)
        question.max_length = 3
        question.should_not be_valid
        question.should have(1).error_on(:max_length)
      end
    end

    context "when updating a non-finalized question" do
      it "allows updation of all fields" do
        question = FactoryGirl.create(:question)
        question.max_length = 3
        question.mandatory = true
        question.should be_valid
      end
    end



    it "allows multiple rows to have nil for order_number" do
      survey = FactoryGirl.create(:survey)
      FactoryGirl.create(:question, :order_number => nil, :survey_id => survey.id)
      another_question = FactoryGirl.build(:question, :order_number => nil, :survey_id => survey.id)
      another_question.should be_valid
    end

    it "ensures that the order number for a question is unique within a survey" do
      survey = FactoryGirl.create(:survey)
      question_1 = FactoryGirl.create(:question, :survey => survey, :order_number => 1)
      question_2 = FactoryGirl.build(:question, :survey => survey, :order_number => 1)
      question_2.should_not be_valid
    end

    it "ensures that the order number for a question is unique within its parent's scope" do
      survey = FactoryGirl.create(:survey)
      question_1 = FactoryGirl.create(:question, :survey => survey, :order_number => 1, :parent_id => 5)
      question_2 = FactoryGirl.build(:question, :survey => survey, :order_number => 1, :parent_id => 5)
      question_2.should_not be_valid
    end

    it "allows duplicate order numbers for questions with different parents within a survey" do
      survey = FactoryGirl.create(:survey)
      question_1 = FactoryGirl.create(:question, :survey => survey, :order_number => 1, :parent_id => 1)
      question_2 = FactoryGirl.create(:question, :survey => survey, :order_number => 1, :parent_id => 2)
      question_2.should be_valid
    end

    it "allows duplicate order numbers for questions with different parent categories within a survey" do
      survey = FactoryGirl.create(:survey)
      question_1 = FactoryGirl.create(:question, :survey => survey, :order_number => 1, :category_id => 1)
      question_2 = FactoryGirl.create(:question, :survey => survey, :order_number => 1, :category_id => 2)
      question_2.should be_valid
    end
  end

  context "orders by order number" do
    it "fetches all question in ascending order of order_number for a particular survey" do
      survey = FactoryGirl.create(:survey)
      question = FactoryGirl.create(:question, :survey => survey)
      another_question = FactoryGirl.create(:question, :survey => survey)
      survey.questions == [question, another_question]
      question.order_number.should be < another_question.order_number
    end
  end

  it "creates a question of a given type" do
    question_params = { content: "Untitled question", survey_id: 18, order_number: 1}
    type = "SingleLineQuestion"
    question = Question.new_question_by_type(type, question_params)
    question.class.name.should == "SingleLineQuestion"
  end

  context "#json" do
    it "fetches all the questions nested directly under it for a RadioQuestion" do
      question = FactoryGirl.create(:radio_question)
      nested_question = FactoryGirl.create(:single_line_question, :parent => FactoryGirl.create(:option, :question => question))
      nested_json = nested_question.as_json(:methods => [:type, :options])
      # Need to do a #to_s because for some reason the direct hash comparison fails on ActiveSupport::TimeWithZone objects on Linux machines
      question.json[:options][0][:questions].map(&:to_s).should include nested_json.to_s
    end

    it "fetches all the questions nested directly under it for a DropDownQuestion" do
      question = FactoryGirl.create(:drop_down_question)
      nested_question = FactoryGirl.create(:single_line_question, :parent => FactoryGirl.create(:option, :question => question))
      question.json[:options][0][:questions].map(&:to_s).should include nested_question.as_json(:methods => [:type, :options]).to_s
    end

    it "returns self for all other types of questions" do
      question = FactoryGirl.create(:question)
      question.json.should include(question.as_json)
    end

    it "returns questions nested all levels below it" do
      first_level_question = FactoryGirl.create(:radio_question)
      second_level_question = FactoryGirl.create(:radio_question, :parent => FactoryGirl.create(:option, :question => first_level_question))
      third_level_question = FactoryGirl.create(:radio_question, :parent => FactoryGirl.create(:option, :question => second_level_question))
      first_level_question.json[:options][0][:questions].map(&:to_s).should include(second_level_question.json(:methods => :type).to_s)
      first_level_question.json[:options][0][:questions][0][:options][0][:questions].map(&:to_s).should include(third_level_question.json(:methods => :type).to_s)
    end
  end

  it "knows if it is a first level question" do
    question = FactoryGirl.create(:radio_question)
    category = FactoryGirl.create(:category)
    sub_question = FactoryGirl.create(:radio_question, :parent => FactoryGirl.create(:option, :question => question))
    question_under_category = FactoryGirl.create(:question, :category => category)
    question.should be_first_level
    sub_question.should_not be_first_level
    question_under_category.should_not be_first_level
  end

  context "when fetching question with its elements in order as json" do
    it "includes itself" do
      question = FactoryGirl.create(:question, :type => 'SingleLineQuestion')
      json = question.as_json_with_elements_in_order
      %w(type content id parent_id type category_id).each do |attr|
        json[attr].should == question[attr]
      end
    end
  end

  context "when fetching a question with its questions in order" do
    it "includes itself" do
      question = FactoryGirl.create(:question, :type => 'SingleLineQuestion')
      question.ordered_question_tree.should == [question]
    end
  end

  it "returns parent question of current child question" do
    question = FactoryGirl.create(:drop_down_question)
    nested_question = FactoryGirl.create(:drop_down_question, :parent => FactoryGirl.create(:option, :question => question))
    nested_question.parent_question.should == question
  end

  context "when returning it's level of nesting" do
    it "takes into account nesting under an option" do
      first_level_question = FactoryGirl.create(:drop_down_question)
      second_level_question = FactoryGirl.create(:drop_down_question, :parent => FactoryGirl.create(:option, :question => first_level_question))
      third_level_question = FactoryGirl.create(:drop_down_question, :parent => FactoryGirl.create(:option, :question => second_level_question))
      first_level_question.nesting_level.should == 1
      second_level_question.nesting_level.should == 2
      third_level_question.nesting_level.should == 3
    end

    it "takes into account nesting under a category" do
      first_level_question = FactoryGirl.create(:drop_down_question)
      second_level_category = FactoryGirl.create(:category, :parent => FactoryGirl.create(:option, :question => first_level_question))
      third_level_question = FactoryGirl.create(:question, :category => second_level_category)
      first_level_question.nesting_level.should == 1
      third_level_question.nesting_level.should == 3
    end
  end

  context "reports" do
    it "has no report data" do
      FactoryGirl.create(:question).report_data.should be_empty
    end

    context "when getting answers for reports" do
      it "gets answers belonging to clean, complete responses" do
        response = FactoryGirl.create(:response, :clean, :complete)
        question = FactoryGirl.create(:question, :finalized)
        answer = FactoryGirl.create(:answer, :question => question, :response => response)
        question.answers_for_reports.should include answer
      end

      it "doesn't get an answer if its response is not clean" do
        response = FactoryGirl.create(:response, :complete, :state => 'dirty')
        question = FactoryGirl.create(:question, :finalized)
        answer = FactoryGirl.create(:answer, :question => question, :response => response)
        question.answers_for_reports.should_not include answer
      end

      it "doesn't get an answer if its response is incomplete" do
        response = FactoryGirl.create(:response, :clean, :incomplete)
        question = FactoryGirl.create(:question, :finalized)
        answer = FactoryGirl.create(:answer, :question => question, :response => response)
        question.answers_for_reports.should_not include answer
      end
    end
  end

  context "duplicate" do
    let(:survey) { FactoryGirl.create(:survey) }

    it "duplicates questions" do
      question = FactoryGirl.create(:question, :content => "foo question")
      duplicated_question = question.duplicate(survey.id)
      duplicated_question.id.should_not == question.id
      duplicated_question.survey_id.should == survey.id
      duplicated_question.content.should == "foo question"
    end

    it "duplicates question with sub questions" do
      question = FactoryGirl.create(:drop_down_question)
      nested_question = FactoryGirl.create(:drop_down_question, :content => "foo nested", :parent => FactoryGirl.create(:option, :question => question))
      duplicated_question = question.duplicate(survey.id)
      duplicated_nested_questions = duplicated_question.options.map(&:questions).flatten
      duplicated_nested_questions.map(&:id).should_not == [nested_question.id]
      duplicated_nested_questions.map(&:survey_id).should == [survey.id]
      duplicated_nested_questions.map(&:content).should == ["foo nested"]
    end

    it "creates a non-finalized question, whether the original is finalized or not" do
      question = FactoryGirl.create(:question, :finalized)
      duplicated_question = question.duplicate(survey.id)
      duplicated_question.should_not be_finalized
    end

    it "duplicates the question's image" do
      image = fixture_file_upload('/images/sample.jpg', 'image/jpeg')
      question = FactoryGirl.create(:question, :image => image)
      FakeWeb.register_uri(:get, question.image_url, :body => "IMAGE")
      duplicated_question = question.duplicate(survey.id)
      duplicated_question.image_url.should_not be_nil
      duplicated_question.image_url.should_not == question.image_url
    end
  end

  it "returns the index of the parent's option amongst its siblings" do
    question = FactoryGirl.create(:multi_choice_question)
    FactoryGirl.create(:option, :question => question, :order_number => 5)
    parent_option = FactoryGirl.create(:option, :question => question, :order_number => 10)
    FactoryGirl.create(:option, :question => question, :order_number => 15)
    sub_question = FactoryGirl.create(:single_line_question, :parent => parent_option)
    sub_question.index_of_parent_option.should == 1
  end

  context "copy" do
    it "assigns the correct order_number to the duplicated question" do
      question = FactoryGirl.create(:question)
      question.copy_with_order
      Question.find_by_order_number(question.order_number + 1).should_not be_nil
    end

    it "duplicates question with sub questions" do
      question = FactoryGirl.create(:drop_down_question, order_number: 0)
      nested_question = FactoryGirl.create(:drop_down_question, order_number: 0, :parent => FactoryGirl.create(:option, :question => question))
      question.copy_with_order
      duplicated_question = Question.find_by_order_number(question.order_number + 1)
      duplicated_question.id.should_not == question.id
      duplicated_question.content.should == question.content
      duplicated_question.options.first.questions.size.should == question.options.first.questions.size
    end

    it "sets the sub-questions' survey ID to the same survey_id as of the original question" do
      question = FactoryGirl.create(:drop_down_question, :order_number => 0)
      option = FactoryGirl.create(:option, :question => question)
      nested_question = FactoryGirl.create(:drop_down_question, parent: option)
      question.copy_with_order
      duplicated_question = Question.find_by_order_number(1)
      duplicated_question.options[0].questions[0].survey_id.should == question.survey_id
    end
  end

  context "#has_multi_record_ancestor?" do
    it "returns true if its parent option has a multi record ancestor" do
      mr_category = FactoryGirl.create(:multi_record_category)
      parent_question = FactoryGirl.create(:question_with_options, :category => mr_category)
      option = FactoryGirl.create(:option, :question => parent_question)
      question = FactoryGirl.create(:question, :parent => option)
      question.should have_multi_record_ancestor
    end

    it "returns false if its parent option doesn't have a multi record ancestor" do
      category = FactoryGirl.create(:category)
      parent_question = FactoryGirl.create(:question_with_options, :category => category)
      option = FactoryGirl.create(:option, :question => parent_question)
      question = FactoryGirl.create(:question, :parent => option)
      question.should_not have_multi_record_ancestor
    end

    it "returns true if its parent category has a multi record ancestor" do
      ancestor_category = FactoryGirl.create(:multi_record_category)
      category = FactoryGirl.create(:category, :category => ancestor_category)
      question = FactoryGirl.create(:question, :category => category)
      question.should have_multi_record_ancestor
    end

    it "returns false if its parent category doesn't have a multi record ancestor" do
      ancestor_category = FactoryGirl.create(:category)
      category = FactoryGirl.create(:category, :category => ancestor_category)
      question = FactoryGirl.create(:question, :category => category)
      question.should_not have_multi_record_ancestor
    end

    it "returns true if there is a multi-record category higher up in the chain" do
      mr_category = FactoryGirl.create(:multi_record_category)
      category = FactoryGirl.create(:category, :category => mr_category)
      question = FactoryGirl.create(:question_with_options, :category => category)
      option = FactoryGirl.create(:option, :question => question)
      option.should have_multi_record_ancestor
    end

    it "returns true if its parent category is a multi-record category" do
      category = FactoryGirl.create(:multi_record_category)
      question = FactoryGirl.create(:question, :category => category)
      question.should have_multi_record_ancestor
    end

    it "returns false if its parent category is not a multi-record category" do
      category = FactoryGirl.create(:category)
      question = FactoryGirl.create(:question, :category => category)
      question.should_not have_multi_record_ancestor
    end
  end

  context "when finding or initializing answers for a response" do
    let(:response) { FactoryGirl.create :response }

    it "initializes an empty answer" do
      question = FactoryGirl.create(:question, :finalized)
      answer = question.find_or_initialize_answers_for_response(response)
      answer.question_id.should == question.id
    end

    it "initializes an empty answer belonging to the passed response" do
      question = FactoryGirl.create(:question, :finalized)
      response = FactoryGirl.create(:response)
      answer = question.find_or_initialize_answers_for_response(response)
      answer.response_id.should == response.id
    end

    it "initializes an answer belonging to a record (if specified)" do
      record = FactoryGirl.create(:record)
      question = FactoryGirl.create(:question, :finalized)
      answer = question.find_or_initialize_answers_for_response(response, :record_id => record.id)
      answer.record_id.should == record.id
    end

    it "returns an existing answer if it exists" do
      question = FactoryGirl.create(:question, :finalized)
      answer = FactoryGirl.create(:answer, :question => question, :response => response)
      question.find_or_initialize_answers_for_response(response).should == answer
    end
  end

  it "returns an empty array if a question doesn't have option" do
    question = FactoryGirl.create(:question, :max_length => 5)
    question.options.should be_empty
  end

  include_examples 'a question'
end
