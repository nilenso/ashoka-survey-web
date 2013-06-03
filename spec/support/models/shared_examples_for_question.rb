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


  context "for images" do
    it "returns the image in base64 format" do
      question = FactoryGirl.create(:photo_question)
      question.image_in_base64.should == Base64.encode64(File.read(question.image.thumb.path))
    end
  end
end
