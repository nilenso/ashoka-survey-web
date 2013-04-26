require 'spec_helper'

describe ResponsesExcelJob do
  METADATA_SIZE = 6

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
      ws.should have_header_cell("Foo Option")
    end

    it "should include the metadata information" do
      Geocoder.configure(:lookup => :test)
      Geocoder::Lookup::Test.set_default_stub([{ 'address' => 'foo_location' }])
      user_names = { 1 => "hansel", 2 => "gretel" }
      organization_names = [Organization.new(1, "C42"), Organization.new(2, "Ashoka")]
      response = FactoryGirl.create(:response, :user_id => 1, :ip_address => "0.0.0.0", :organization_id => 1, :state => "dirty")
      job = ResponsesExcelJob.new(survey, [response.id], organization_names, user_names, server_url, filename)
      ws = job.package.workbook.worksheets[0]
      ["hansel", "C42", "foo_location", "0.0.0.0", "dirty"].each { |md| ws.should have_cell(md).in_row(1) }
    end
  end

  context "when setting the answers for a response" do
    it "includes the answer for each question" do
      response = FactoryGirl.create(:response, :survey => survey)
      question = FactoryGirl.create(:question, :survey => survey)
      answer = FactoryGirl.create(:answer, :question => question, :response => response, :content => "answer_foo")
      job = ResponsesExcelJob.new(survey, [response.id], organization_names, user_names, server_url, filename)
      ws = job.package.workbook.worksheets[0]
      ws.should have_cell("answer_foo").in_row(1)
    end

    context "when setting answers for a multi-choice question" do
      it "insert a single blank cell corresponding to the question" do
        response = FactoryGirl.create(:response, :survey => survey)
        question = MultiChoiceQuestion.create(:content => "foo_content")
        question.update_column(:survey_id, survey.id)
        answer = FactoryGirl.create(:answer, :question => question, :response => response)
        job = ResponsesExcelJob.new(survey, [response.id], organization_names, user_names, server_url, filename)
        ws = job.package.workbook.worksheets[0]
        ws.rows[1].cells[1].value.should == ""
      end

      it "subsequently inserts a cell for each option" do
        response = FactoryGirl.create(:response, :survey => survey)
        question = MultiChoiceQuestion.create(:content => "foo_content")
        question.update_column(:survey_id, survey.id)
        options = FactoryGirl.create_list(:option, 5, :question => question)
        answer = FactoryGirl.create(:answer, :question => question, :response => response)
        job = ResponsesExcelJob.new(survey, [response.id], organization_names, user_names, server_url, filename)
        ws = job.package.workbook.worksheets[0]
        ws.rows[1].cells[2..-1].size.should == (options.size + METADATA_SIZE)        
      end      
    end

    context "when setting answers for questions in a multi-record category" do
      it "inserts a comma-separated list of answers; one from each record" do
        response = FactoryGirl.create(:response, :survey => survey)
        category = MultiRecordCategory.create(:content => "foo_category", :survey_id => survey.id)
        question = FactoryGirl.create(:question, :category => category, :survey => survey)
        answer_one = FactoryGirl.create(:answer_in_record, :question => question, :response => response, :content => "foo_answer")
        answer_two = FactoryGirl.create(:answer_in_record, :question => question, :response => response, :content => "bar_answer")
        job = ResponsesExcelJob.new(survey, [response.id], organization_names, user_names, server_url, filename)
        ws = job.package.workbook.worksheets[0]
        ws.should have_cell_containing("foo_answer").in_row(1)
        ws.should have_cell_containing("bar_answer").in_row(1)
      end

      it "inserts the answers for each question in the same order of records" do
        category = MultiRecordCategory.create(:content => "foo_category", :survey_id => survey.id)
        question_one = FactoryGirl.create(:question, :category => category, :survey => survey)
        question_two = FactoryGirl.create(:question, :category => category, :survey => survey)
        response = FactoryGirl.create(:response, :survey => survey)

        record_one = FactoryGirl.create(:record, :response => response)
        FactoryGirl.create(:answer, :question => question_one, :response => response, :content => "foo_answer", :record => record_one)
        FactoryGirl.create(:answer, :question => question_two, :response => response, :content => "x_answer", :record => record_one)

        record_two = FactoryGirl.create(:record, :response => response)
        FactoryGirl.create(:answer, :question => question_one, :response => response, :content => "bar_answer", :record => record_two)
        FactoryGirl.create(:answer, :question => question_two, :response => response, :content => "y_answer", :record => record_two)

        job = ResponsesExcelJob.new(survey, [response.id], organization_names, user_names, server_url, filename)
        ws = job.package.workbook.worksheets[0]

        ws.should have_cell("foo_answer, bar_answer").in_row(1)
        ws.should have_cell("x_answer, y_answer").in_row(1)
      end
    end
  end
end
