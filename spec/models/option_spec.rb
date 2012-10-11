require 'spec_helper'

describe Option do
  it { should belong_to(:question) }
  it { should respond_to(:content) }
  it { should allow_mass_assignment_of(:content) }
  it { should allow_mass_assignment_of(:question_id) }
  it { should validate_presence_of(:content) }
  it { should validate_presence_of(:question_id) }
  it { should have_many(:questions) }

  context "validation" do
    it "Ensures that the order number for an option is unique within a question" do
      question = RadioQuestion.create( :type => "RadioQuestion", :content => "hollo!")
      option_1 = FactoryGirl.create(:option, :question => question, :order_number => 1)
      option_2 = FactoryGirl.build(:option, :question => question, :order_number => 1)
      option_2.should_not be_valid
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

  context "when fetching all the sub_questions of an option" do
    let(:question) { FactoryGirl.create :question }

    it "fetches all the directly nested sub_questions" do      
      option = Option.create(content: "Option", order_number: 2, :question_id => question.id)
      nested_question = RadioQuestion.create({content: "Nested", survey_id: 18, order_number: 1, parent_id: option.id})
      option.as_json[:questions].should include nested_question.as_json
    end

    it "fetches the nested subquestions at all levels" do      
      option = Option.create(content: "Option", order_number: 2, :question_id => question.id)
      nested_question = RadioQuestion.create({content: "Nested", survey_id: 18, order_number: 1, parent_id: option.id})
      nested_question.options << Option.create(content: "Option", order_number: 2, :question_id => nested_question.id)
      another_nested_question = RadioQuestion.create({content: "Nested", survey_id: 18, order_number: 1, parent_id: nested_question.options.first.id})
      option.as_json[:questions].should include nested_question.as_json
      option.as_json[:questions].should_not include  another_nested_question.as_json
    end

    it "returns itself when there are no sub_questions" do      
      option = Option.create(content: "Option", order_number: 2, :question_id => question.id)
      option.as_json.should == option.as_json
    end
  end
end
