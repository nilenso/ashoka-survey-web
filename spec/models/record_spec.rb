require 'spec_helper'

describe Record do
  it { should belong_to :category }
  it { should have_many(:answers).dependent(:destroy) }
  it { should allow_mass_assignment_of(:category_id) }
  it { should allow_mass_assignment_of(:response_id) }

  it { should validate_presence_of(:response_id) }
  it { should validate_presence_of(:category_id) }

  context "after creation" do
    it "creates answers for all its category's questions" do
      category = FactoryGirl.create :category
      category.questions << FactoryGirl.create_list(:question, 5)
      record = FactoryGirl.create :record, :category => category
      record.answers.length.should == 5
      record.answers.map(&:question_id).should =~ category.questions.map(&:id)
    end
  end

  context "when fetching answers" do
    let(:response) { FactoryGirl.create :response }

    it "returns a list of all the answers sorted by their question's order number" do
      mr_category = MultiRecordCategory.create(:content => "foo")
      record = FactoryGirl.create(:record, :category => mr_category, :response => response)

      sub_question_2 = FactoryGirl.create(:question, :category => mr_category, :order_number => 2)
      sub_question_1 = FactoryGirl.create(:question, :category => mr_category, :order_number => 1)

      answer_2 = FactoryGirl.create(:answer, :question => sub_question_2, :record => record)
      answer_1 = FactoryGirl.create(:answer, :question => sub_question_1, :record => record)

      record.sorted_answers.should == [answer_1, answer_2]
    end
  end
end
