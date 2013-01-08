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
    context "when encoding in base64" do
      it "returns the cached image if the remote image is still uploading" do
        question = FactoryGirl.create :question
        question.image.stub(:cache_dir).and_return("spec/fixtures/images")
        question.image_tmp = 'sample.jpg'
        question.image_in_base64.should == Base64.encode64(File.read('spec/fixtures/images/sample.jpg'))
      end

      it "returns the remote image if it's done uploading" do
        question = FactoryGirl.create :question_with_image
        question.image_in_base64.should == Base64.encode64(File.read(question.image.thumb.path))
      end
    end

    context "when getting the URL" do
      it "returns the relative URL to the cached (local) image if the S3 version hasn't uploaded" do
        question = FactoryGirl.create :question
        question.image.stub(:cache_url).and_return("spec/fixtures/images")
        question.image_tmp = 'sample.jpg'
        question.image_url.should == '/spec/fixtures/images/sample.jpg'
      end

      it "returns the URL to the S3 version if it's uploaded" do
        question = FactoryGirl.create :question_with_image
        question.image_tmp = nil
        question.image_url.should == question.image.url
      end

      it "takes a format (medium or thumb) which it returns only for the S3 version" do
        question = FactoryGirl.create :question_with_image
        question.image_tmp = nil
        question.image_url(:thumb).should == question.image.thumb.url
      end

      it "returns nil if the question doesn't have an image" do
        question = FactoryGirl.create :question
        question.image_url.should be_nil
      end
    end
  end
end
