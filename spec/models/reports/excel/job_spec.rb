require 'spec_helper'

describe Reports::Excel::Job do
  let(:survey) { FactoryGirl.create(:survey) }
  let(:responses) { FactoryGirl.create_list(:response, 5, :survey => survey) }
  let(:server_url) { "http://example.com" }
  let(:metadata) { Reports::Excel::Metadata.new(responses, @access_token, :disable_filtering => true) }

  before(:each) do
    @access_token = mock(OAuth2::AccessToken)
    @orgs_response = mock(OAuth2::Response)
    @access_token.stub(:get).with('/api/organizations').and_return(@orgs_response)
    @orgs_response.stub(:parsed).and_return([
      {"id" => 1, "name" => "CSOOrganization", "logos" => {"thumb_url" => "http://foo.png"}},
      {"id" => 2, "name" => "Ashoka", "logos" => {"thumb_url" => "http://foo.png"}}
    ])
    @names_response = mock(OAuth2::Response)
    @access_token.stub(:get).with('/api/users/users_for_ids', :params => {:user_ids => [1].to_json}).and_return(@names_response)
    @names_response.stub(:parsed).and_return([{"id" => 1, "name" => "Bob"}])
  end

  it "sets first cell of each row to the serial number of that response" do
    responses = FactoryGirl.create_list(:response, 5, :survey => survey, :status => "complete")
    data = Reports::Excel::Data.new(survey, [], responses, server_url, metadata)
    job = Reports::Excel::Job.new(data)
    wb = job.package.workbook
    col = wb.worksheets[0].cols[0]
    col.map(&:value).should == ["Response No.", 1, 2, 3, 4, 5]
  end

  context "when setting the headers in the first row" do
    it "should have questions for the survey" do
      questions = []
      questions << FactoryGirl.create(:question, :survey => survey, :content => "foo")
      questions << FactoryGirl.create(:question, :survey => survey, :content => "bar")
      data = Reports::Excel::Data.new(survey, questions, responses, server_url, metadata)
      job = Reports::Excel::Job.new(data)
      ws = job.package.workbook.worksheets[0]
      question_cells = ws.rows[0].cells[1..2]
      question_cells.each.with_index do |q, i|
        q.value.should include questions[i].content
      end
    end

    it "should include each option for all the multi-choice questions" do
      question_with_options = FactoryGirl.create(:multi_choice_question)
      question_with_options.update_column :survey_id, survey.id
      option_foo = FactoryGirl.create(:option, :question => question_with_options, :content => "Foo Option")
      data = Reports::Excel::Data.new(survey, [question_with_options], responses, server_url, metadata)
      job = Reports::Excel::Job.new(data)
      ws = job.package.workbook.worksheets[0]
      ws.should have_header_cell("Foo Option")
    end

    it "should include the metadata information" do
      @orgs_response.stub(:parsed).and_return([
        {"id" => 1, "name" => "C42", "logos" => {"thumb_url" => "http://foo.png"}},
        {"id" => 2, "name" => "Ashoka", "logos" => {"thumb_url" => "http://foo.png"}}])
      @names_response.stub(:parsed).and_return([{"id" => 1, "name" => "hansel"}])

      stub_geocoder(:address => "foo_location")

      response = FactoryGirl.create(:response, :user_id => 1, :ip_address => "0.0.0.0", :organization_id => 1, :state => "dirty")
      data = Reports::Excel::Data.new(survey, [], [response], server_url, metadata)
      job = Reports::Excel::Job.new(data)
      ws = job.package.workbook.worksheets[0]
      ["hansel", "C42", "foo_location", "0.0.0.0", "dirty"].each { |md| ws.should have_cell(md).in_row(1) }
    end
  end

  context "when setting the answers for a response" do
    it "includes the answer for each question" do
      response = FactoryGirl.create(:response, :survey => survey)
      question = FactoryGirl.create(:question, :finalized, :survey => survey)
      answer = FactoryGirl.create(:answer, :question => question, :response => response, :content => "answer_foo")
      data = Reports::Excel::Data.new(survey, [question], [response], server_url, metadata)
      job = Reports::Excel::Job.new(data)
      ws = job.package.workbook.worksheets[0]
      ws.should have_cell("answer_foo").in_row(1)
    end

    context "when setting answers for a multi-choice question" do
      it "insert a single blank cell corresponding to the question" do
        response = FactoryGirl.create(:response, :survey => survey)
        question = FactoryGirl.create(:multi_choice_question, :finalized)
        question.update_column(:survey_id, survey.id)
        answer = FactoryGirl.create(:answer, :question => question, :response => response)
        data = Reports::Excel::Data.new(survey, [question], [response], server_url, metadata)
        job = Reports::Excel::Job.new(data)
        ws = job.package.workbook.worksheets[0]
        ws.rows[1].cells[1].value.should == ""
      end

      it "subsequently inserts a cell for each option" do
        response = FactoryGirl.create(:response, :survey => survey)
        question = FactoryGirl.create(:multi_choice_question, :finalized)
        question.update_column(:survey_id, survey.id)
        options = FactoryGirl.create_list(:option, 5, :question => question)
        answer = FactoryGirl.create(:answer, :question => question, :response => response)
        data = Reports::Excel::Data.new(survey, [question], [response], server_url, metadata)
        job = Reports::Excel::Job.new(data)
        ws = job.package.workbook.worksheets[0]
        ws.rows[1].cells[2..-1].size.should == (options.size + metadata.headers.size)
      end
    end

    context "when setting answers for questions in a multi-record category" do
      it "inserts a comma-separated list of answers; one from each record" do
        response = FactoryGirl.create(:response, :survey => survey)
        category = MultiRecordCategory.create(:content => "foo_category", :survey_id => survey.id)
        question = FactoryGirl.create(:question, :finalized, :category => category, :survey => survey)
        answer_one = FactoryGirl.create(:answer_in_record, :question => question, :response => response, :content => "foo_answer")
        answer_two = FactoryGirl.create(:answer_in_record, :question => question, :response => response, :content => "bar_answer")
        data = Reports::Excel::Data.new(survey, [question], [response], server_url, metadata)
        job = Reports::Excel::Job.new(data)
        ws = job.package.workbook.worksheets[0]
        ws.should have_cell_containing("foo_answer").in_row(1)
        ws.should have_cell_containing("bar_answer").in_row(1)
      end

      it "inserts the answers for each question in the same order of records" do
        category = MultiRecordCategory.create(:content => "foo_category", :survey_id => survey.id)
        question_one = FactoryGirl.create(:question, :finalized, :category => category, :survey => survey)
        question_two = FactoryGirl.create(:question, :finalized, :category => category, :survey => survey)
        response = FactoryGirl.create(:response, :survey => survey)

        record_one = FactoryGirl.create(:record, :response => response)
        FactoryGirl.create(:answer, :question => question_one, :response => response, :content => "foo_answer", :record => record_one)
        FactoryGirl.create(:answer, :question => question_two, :response => response, :content => "x_answer", :record => record_one)

        record_two = FactoryGirl.create(:record, :response => response)
        FactoryGirl.create(:answer, :question => question_one, :response => response, :content => "bar_answer", :record => record_two)
        FactoryGirl.create(:answer, :question => question_two, :response => response, :content => "y_answer", :record => record_two)

        data = Reports::Excel::Data.new(survey, [question_one, question_two], [response], server_url, metadata)
        job = Reports::Excel::Job.new(data)
        ws = job.package.workbook.worksheets[0]

        ws.should have_cell("foo_answer, bar_answer").in_row(1)
        ws.should have_cell("x_answer, y_answer").in_row(1)
      end
    end
  end

  it "creates the ZIP file with an appropriate filename" do
    connection = Fog::Storage.new(:provider => "AWS",
                                  :aws_secret_access_key => ENV['S3_SECRET'],
                                  :aws_access_key_id => ENV['S3_ACCESS_KEY'])
    connection.directories.create(:key => 'surveywebexcel')

    data = Reports::Excel::Data.new(survey, [], responses, server_url, metadata)
    Reports::Excel::Job.new(data).perform

    connection.directories.get("surveywebexcel").files.get(data.file_name + ".zip").should be_present
  end

  it "enqueues a delayed job which will run it's own perform method" do
    data = Reports::Excel::Data.new(survey, [], responses, server_url, metadata)
    job = Reports::Excel::Job.new(data)
    expect { job.start }.to change { Delayed::Job.where(:queue => 'generate_excel').count }.by(1)
  end
end
