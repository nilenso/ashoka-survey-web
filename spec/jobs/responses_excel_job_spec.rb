require 'spec_helper'

describe ResponsesExcelJob do
  let(:survey) { FactoryGirl.create(:survey) }
  let(:organization_names) { [Organization.new(1, "C42")] }
  let(:user_names) { { 1 => "Han", 2 => "Solo" } }
  let(:server_url) { "http://example.com" }
  let(:filename) { "foo.xlsx" }
  let(:response_ids) { FactoryGirl.create_list(:response, 5, :survey => survey).map(&:id) }

  it "sets first cell of each row to the serial number of that response" do
    response_ids = FactoryGirl.create_list(:response, 5, :survey => survey).map(&:id)
    job = ResponsesExcelJob.new(survey, response_ids, organization_names, user_names, server_url, filename)
    wb = job.package.workbook
    col = wb.worksheets[0].cols[0]
    col.map(&:value).should == ["Response No.", 1, 2, 3, 4, 5]
  end

  context "when setting the headers in the first row" do
    it "should have questions for the survey" do
      questions = []
      questions << FactoryGirl.create(:question, :survey => survey, :content => "foo")
      questions << FactoryGirl.create(:question, :survey => survey, :content => "bar")
      job = ResponsesExcelJob.new(survey, response_ids, organization_names, user_names, server_url, filename)
      ws = job.package.workbook.worksheets[0]
      question_cells = ws.rows[0].cells[1..2]
      question_cells.each.with_index do |q, i|
        q.value.should include questions[i].content
      end
    end

    it "should include each option for all the multi-choice questions" do
      question_with_options = MultiChoiceQuestion.create(:content => "Foo")
      question_with_options.update_column :survey_id, survey.id
      option_foo = FactoryGirl.create(:option, :question => question_with_options, :content => "Foo Option")
      job = ResponsesExcelJob.new(survey, response_ids, organization_names, user_names, server_url, filename)
      ws = job.package.workbook.worksheets[0]
      ws.rows[0].cells.map(&:value).should include "Foo Option"
    end

    it "should include the metadata information" do
      Geocoder.configure(:lookup => :test)
      Geocoder::Lookup::Test.set_default_stub([{ 'address' => 'foo_location' }])

      metadata_size = 6
      user_names = { 1 => "hansel", 2 => "gretel" }
      organization_names = [Organization.new(1, "C42"), Organization.new(2, "Ashoka")]
      response = FactoryGirl.create(:response, :user_id => 1, :ip_address => "0.0.0.0", :organization_id => 1, :state => "dirty")
      job = ResponsesExcelJob.new(survey, [response.id], organization_names, user_names, server_url, filename)
      ws = job.package.workbook.worksheets[0]
      ws.rows[1].cells.last(metadata_size).map(&:value).should == ["hansel", "C42", response.last_update, "foo_location", "0.0.0.0", "dirty"] 
    end
  end
end
