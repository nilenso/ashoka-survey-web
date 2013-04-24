class ResponsesExcelJob < Struct.new(:survey, :response_ids, :organization_names, :user_names, :server_url, :filename)
  def perform
    return if response_ids.empty?
    package = Axlsx::Package.new do |p|
      wb = p.workbook
      bold_style = wb.styles.add_style sz: 12, b: true, alignment: { horizontal: :center }
      border = wb.styles.add_style border: { style: :thin, color: '000000' }
      questions = survey.questions_in_order.map(&:reporter)
      wb.add_worksheet(name: "Responses") do |sheet|
        headers = questions.map(&:header).flatten
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
            question.formatted_answers_for(question_answers, :server_url => server_url)
          end.flatten
          answers_for_excel.unshift(i+1)
          answers_for_excel += metadata_for(response)          
          sheet.add_row answers_for_excel, style: border
        end
      end
    end

    directory = aws_excel_directory
    directory.files.create(:key => filename, :body => package.to_stream, :public => true)
  end

  def metadata_for(response)
    [user_name_for(response), organization_name_for(response), response.last_update,
      response.location, response.ip_address, response.state]
  end

  def user_name_for(response)
    user_names[response.user_id]
  end

  def organization_name_for(response)
    organization_names.find { |org| org.id == response[:organization_id] }.try(:name)
  end


  def error(job, exception)
    Airbrake.notify(exception)
  end

  private

  def aws_excel_directory
    connection = Fog::Storage.new(:provider => "AWS",
                                  :aws_secret_access_key => ENV['S3_SECRET'],
                                  :aws_access_key_id => ENV['S3_ACCESS_KEY'])
    connection.directories.get('surveywebexcel')
  end
end
