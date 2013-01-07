require 'spec_helper'

shared_examples "a question" do
  let(:question) { described_class.create(:content => "foo", :survey_id => 666) }

  it { should respond_to :content }
  it { should respond_to :mandatory }
  it { should validate_presence_of :content }
  it { should respond_to(:image) }
  it { should belong_to :survey }
  it { should have_many(:answers).dependent(:destroy) }

  context "mass assignment" do
    it { should allow_mass_assignment_of(:content) }
    it { should allow_mass_assignment_of(:mandatory) }
    it { should allow_mass_assignment_of(:image) }
  end

  context "image_url" do
    it "returns the image_url if the question has an image" do
      question.image = File.new(Rails.root + 'spec/fixtures/images/sample.jpg')
      question.save
      question.reload.image_url.should == question.image.url(:thumb)
    end
    it "returns nil if the question doesn't have an image" do
      question.image_url.should be_nil
    end
  end
end
