require 'spec_helper'

describe Option do
  it { should validate_presence_of(:content) }
  it { should validate_presence_of(:question_id) }

  it "delegates `survey` to its parent question" do
    survey = FactoryGirl.create(:survey)
    option = FactoryGirl.create(:option, :question => FactoryGirl.create(:question, :survey => survey))
    option.survey.should == survey
  end

  context "validation" do
    it "Ensures that the order number for an option is unique within a question" do
      question = RadioQuestion.create( :type => "RadioQuestion", :content => "hollo!")
      option_1 = FactoryGirl.create(:option, :question => question, :order_number => 1)
      option_2 = FactoryGirl.build(:option, :question => question, :order_number => 1)
      option_2.should_not be_valid
    end
  end

  context "callbacks" do
    let!(:survey) { FactoryGirl.create(:survey) }
    let!(:question) { FactoryGirl.create(:question, :survey => survey) }

    it "creates even if its survey is finalized" do
      survey.finalize
      expect { Option.create(:content => "FOO",:question_id => question.id) }.to change { Option.count }.by(1)
    end

    it "doesn't update if its survey is finalized" do
      option = FactoryGirl.create(:option, :question => question, :content => "FOO")
      survey.finalize
      option.content = "BAR"
      option.save
      option.reload.content.should == "FOO"
    end

    it "doesn't destroy if its survey is finalized" do
      option = FactoryGirl.create(:option, :question => question, :content => "FOO")
      survey.finalize
      expect { option.destroy }.not_to change { Option.count }
    end
  end

  context "orders by order number" do
    it "fetches all option in ascending order of order_number for a particular question" do
      question = RadioQuestion.create( :content => "hollo!")
      option = FactoryGirl.create(:option, :question => question, :order_number => 2)
      another_option = FactoryGirl.create(:option, :question => question, :order_number => 1)
      question.options.last.should == option
      question.options.first.should == another_option
    end
  end

  it "fetches all it's sub-questions and sub-categories" do
    option = FactoryGirl.create(:option)
    question = FactoryGirl.create :question, :order_number => 0
    category = FactoryGirl.create :category, :order_number => 1
    another_question = FactoryGirl.create :question, :order_number => 2
    option.questions << question
    option.categories << category
    option.questions << another_question

    option.elements.should == [question, category, another_question]
  end

  it "fetches all it's sub-questions and sub-categories with sub_questions" do
    option = FactoryGirl.create(:option)
    question = FactoryGirl.create :question, :order_number => 0
    category = FactoryGirl.create :category, :order_number => 1
    another_category = FactoryGirl.create :category, :order_number => 2
    another_question = FactoryGirl.create :question, :order_number => 2
    option.questions << question
    option.categories << category
    another_category.questions << FactoryGirl.create(:question)
    option.questions << another_question
    option.categories << another_category

    option.elements_with_questions.should == [question, another_question, another_category]
  end

  context "when fetching all the sub_questions of an option" do
    let(:question) { FactoryGirl.create :question }

    it "fetches all the directly nested sub_questions" do
      option = Option.create(content: "Option", order_number: 2, :question_id => question.id)
      nested_question = RadioQuestion.create({content: "Nested", survey_id: 18, order_number: 1, parent_id: option.id})
      # Need to do a #to_s because for some reason the direct hash comparison fails on ActiveSupport::TimeWithZone objects on Linux machines
      option.as_json[:questions].map(&:to_s).should include nested_question.json(:methods => :type).to_s
    end

    it "fetches the nested subquestions at all levels" do
      option = Option.create(content: "Option", order_number: 2, :question_id => question.id)
      nested_question = RadioQuestion.create({content: "Nested", survey_id: 18, order_number: 1, parent_id: option.id})
      nested_question.options << Option.create(content: "Option", order_number: 2, :question_id => nested_question.id)
      another_nested_question = RadioQuestion.create({content: "Nested", survey_id: 18, order_number: 1, parent_id: nested_question.options.first.id})
      option.as_json[:questions].map(&:to_s).should include nested_question.json(:methods => :type).to_s
      option.as_json[:questions].map(&:to_s).should_not include  another_nested_question.json(:methods => :type).to_s
    end

    it "returns itself when there are no sub_questions" do
      option = Option.create(content: "Option", order_number: 2, :question_id => question.id)
      option.as_json.should == option.as_json
    end

    it "includes the `has_multi_record_ancestor` method" do
      option = Option.create(content: "Option", order_number: 2, :question_id => question.id)
      option.as_json.should have_key(:has_multi_record_ancestor)
    end
  end

  context "reports" do
    it "counts the number of times it has been the answer to its question" do
      question = FactoryGirl.create :question
      option = FactoryGirl.create(:option, :question => question)
      5.times { FactoryGirl.create(:answer_with_complete_response, :content => option.content, :question_id => option.question_id) }
      answers = question.answers
      option.report_data(answers).should == 5
    end
  end

  context "duplicate" do
    it "dupicates option and its sub questions" do
      option = FactoryGirl.create(:option)
      option.questions << FactoryGirl.create(:question)
      duplicated_option = option.duplicate(0)
      duplicated_option.id.should_not == option.id
      duplicated_option.content.should == option.content
      duplicated_option.questions.size.should == option.questions.size
    end

    it "dupicates sub categories as well" do
      option = FactoryGirl.create(:option)
      option.categories << FactoryGirl.create(:category)
      duplicated_option = option.duplicate(0)
      duplicated_option.categories.size.should == option.categories.size
    end

    it "sets the sub-question's survey ID to the survey ID of the new survey which is passed in" do
      option = FactoryGirl.create(:option)
      option.questions << FactoryGirl.create(:question)
      duplicated_option = option.duplicate(15)
      duplicated_option.questions[0].survey_id.should == 15
    end

    it "sets the sub-category's survey ID to the survey ID of the new survey which is passed in" do
      option = FactoryGirl.create(:option)
      option.categories << FactoryGirl.create(:category)
      duplicated_option = option.duplicate(15)
      duplicated_option.categories[0].survey_id.should == 15
    end
  end

  it "returns categories with questions" do
    category = FactoryGirl.create :category, :order_number => 0
    another_category = FactoryGirl.create :category, :order_number => 1
    option = FactoryGirl.create(:option)
    option.categories << category
      nested_question = DropDownQuestion.create({content: "Nested", survey_id: 18, order_number: 0, category_id: category.id})
      option.categories_with_questions.should include(category)
      option.categories_with_questions.should_not include(another_category)
  end

  context "#has_multi_record_ancestor" do
    it "returns true if its parent question belongs to a MultiRecordCategory" do
      mr_category = MultiRecordCategory.create(:content => "MR")
      parent_question = FactoryGirl.create(:question_with_options, :category => mr_category)
      option = FactoryGirl.create(:option, :question => parent_question)
      option.should have_multi_record_ancestor
    end

    it "returns false if its parent question belongs to a regular category" do
      category = Category.create(:content => "cat")
      parent_question = FactoryGirl.create(:question_with_options, :category => category)
      option = FactoryGirl.create(:option, :question => parent_question)
      option.should_not have_multi_record_ancestor
    end

    it "returns true if there is a multi-record category higher up in the chain" do
      mr_category = MultiRecordCategory.create(:content => "MR")
      category = FactoryGirl.create(:category, :category => mr_category)
      question = FactoryGirl.create(:question_with_options, :category => category)
      option = FactoryGirl.create(:option, :question => question)
      option.should have_multi_record_ancestor
    end
  end

  context "when fetching an option with its elements in order as json" do
    it "includes itself" do
      option = FactoryGirl.create(:option)
      json = option.as_json_with_elements_in_order
      %w(content id question_id).each do |attr|
        json[attr].should == option[attr]
      end
    end

    it "includes its sub elements" do
      option = FactoryGirl.create(:option)
      sub_question = FactoryGirl.create(:question, :parent => option)
      sub_category = FactoryGirl.create(:category, :parent => option)
      json = option.as_json_with_elements_in_order
      json['elements'].size.should == option.elements.size
    end
  end

  context "when fetching an option with its questions in order" do
    it "does not include itself" do
      option = FactoryGirl.create(:option)
      option.questions_in_order.should_not include option
    end

    it "includes its sub elements" do
      option = FactoryGirl.create(:option)
      sub_question = FactoryGirl.create(:question, :parent => option)
      option.questions_in_order.should == [sub_question]
    end
  end
end
