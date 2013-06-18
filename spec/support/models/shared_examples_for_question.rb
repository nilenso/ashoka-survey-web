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
      image = fixture_file_upload('/images/sample.jpg')
      image_content = image.read
      question = FactoryGirl.create(:question, :image => image)
      question.image.thumb.file.stub(:read).and_return(image_content)
      question.image_in_base64.should == Base64.encode64(image_content)
    end

    it "returns nil if the image doesn't exist" do
      question = FactoryGirl.create(:question)
      question.image_in_base64.should be_nil
    end
  end
end
