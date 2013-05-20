require 'spec_helper'

describe Reports::Excel::Data do
  let(:survey) { FactoryGirl.create(:survey) }
  let(:metadata) { Reports::Excel::Metadata.new([], "accesstoken") }
  let(:server_url) { "http://example.com" }

  it "finds the filename from the survey" do
    data = Reports::Excel::Data.new(survey, [], [], server_url, metadata)
    data.file_name.should == survey.filename_for_excel
  end

  it "does not mutate the filename" do
    data = Reports::Excel::Data.new(survey, [], [], server_url, metadata)
    old_file_name = data.file_name
    Timecop.freeze(5.days.from_now) { data.file_name.should == old_file_name  }
  end

  it "doesn't mutate the filename after serializing/deserializing" do
    data_1 = Reports::Excel::Data.new(survey, [], [], server_url, metadata)
    data_2 = YAML::load(YAML::dump(data_1))
    data_1.file_name.should == Timecop.freeze(1.hour.from_now) { data_2.file_name }
  end

  context "when generating a password" do
    it "generates a random ten-character alphanumeric password" do
      data = Reports::Excel::Data.new(survey, [], [], server_url, metadata)
      data.password.should match /^\w{10}$/
    end

    it "generates the same password for a single instance" do
      data = Reports::Excel::Data.new(survey, [], [], server_url, metadata)
      data.password.should == data.password
    end

    it "doesn't change the password after serializing/deserializing" do
      data_1 = Reports::Excel::Data.new(survey, [], [], server_url, metadata)
      data_2 = YAML::load(YAML::dump(data_1))
      data_1.password.should == data_2.password
    end
  end
end
