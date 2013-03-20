class ResponsesExcelJob < Struct.new(:survey, :response_ids, :organization_names, :user_names, :server_url, :filename)
  def perform
    return if response_ids.empty?
    package = Axlsx::Package.new do |p|
      wb = p.workbook
      bold_style = wb.styles.add_style sz: 12, b: true, alignment: { horizontal: :center }
      border = wb.styles.add_style border: { style: :thin, color: '000000' }
      questions = Response.find(response_ids[0]).sorted_answers.map(&:question)
      wb.add_worksheet(name: "Responses") do |sheet|
        headers = questions.map { |question| "#{QuestionDecorator.find(question).question_number}) #{question.content}" }
        headers.unshift("Response No.")
        headers << "Added By" << "Organization" << "Last updated at" << "Address" << "IP Address" << "State"
        sheet.add_row headers, :style => bold_style
        responses = Response.where('responses.id in (?)', response_ids)
        responses.each_with_index do |response, i|
          response_answers =  Answer.where(:response_id => response[:id])
          .order('answers.record_id')
          .includes(:choices => :option).all
          answers_for_excel = questions.map do |question|
            question_answers = response_answers.find_all { |a| a.question_id == question.id }
            question_answers ? question_answers.map { |answer| answer.content_for_excel(server_url) }.join(', ') : ""
          end
          answers_for_excel.unshift(i+1)
          answers_for_excel << user_names[response.user_id]
          answers_for_excel << organization_names.find { |org| org.id == response[:organization_id] }.try(:name)
          answers_for_excel << response.last_update
          answers_for_excel << response.location
          answers_for_excel << response.ip_address
          answers_for_excel << response.state
          sheet.add_row answers_for_excel, style: border
        end
      end
    end

    connection = Fog::Storage.new(:provider => "AWS",
                                  :aws_secret_access_key=>ENV['S3_SECRET'],
                                  :aws_secret_access_key => ENV['S3_ACCESS_KEY'])
    directory = connection.directories.get('surveywebexcel')
    directory.files.create(:key => filename, :body => package.to_stream, :public => true)
  end

  def after(job)
    delete_excel
  end

  def error(job, exception)
    Airbrake.notify(exception)
  end

  private

  def delete_excel
    connection = Fog::Storage.new(:provider => "AWS",
                                  :aws_secret_access_key=>ENV['S3_SECRET'],
                                  :aws_secret_access_key => ENV['S3_ACCESS_KEY'])
    directory = connection.directories.get('surveywebexcel')
    directory.files.get(filename).destroy
  end
  handle_asynchronously :delete_excel, :run_at => Proc.new { 30.minutes.from_now }, :queue => 'delete_excel'

  def excel_save_path
    if(FileTest.exists?(ENV['EXCEL_SAVE_PATH'].to_s))
      Pathname.new(ENV['EXCEL_SAVE_PATH'])
    else
      Rails.root.join("public")
    end
  end
end
