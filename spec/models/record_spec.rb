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
end
