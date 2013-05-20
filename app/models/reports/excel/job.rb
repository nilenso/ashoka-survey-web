class Reports::Excel::Job < Struct.new(:excel_data)

  def start
    @delayed_job ||= Delayed::Job.enqueue(self, :queue => 'generate_excel')
  end

  def perform
    Tempfile.open('excel', Rails.root.join('tmp')) do |f|
      Zip::Archive.open(f.path, Zip::CREATE) do |ar|
        ar.add_io(excel_data.file_name + ".xlsx", package.to_stream)
        ar.encrypt(excel_data.password)
      end
      directory = aws_excel_directory
      directory.files.create(:key => excel_data.file_name + ".zip", :body => f.open, :public => true)
    end
  end

  # REFACTOR: Use a `sheet` abstraction which internally adds all its rows to a AXSLX worksheet
  # REFACTOR: Use a `style` abstraction
  def package
    return if excel_data.responses.empty?
    Axlsx::Package.new do |p|
      wb = p.workbook
      bold_style = wb.styles.add_style sz: 12, b: true, alignment: { horizontal: :center }
      border = wb.styles.add_style border: { style: :thin, color: '000000' }
      questions = excel_data.questions.map(&:reporter)
      wb.add_worksheet(name: "Responses") do |sheet|
        headers = Reports::Excel::Row.new("Response No.")
        headers << questions.map(&:header)
        headers << excel_data.metadata.headers
        sheet.add_row headers.to_a, :style => bold_style
        excel_data.responses.each_with_index do |response, i|
          response_answers =  Answer.where(:response_id => response[:id])
          .order('answers.record_id')
          .includes(:choices => :option).all
          answers_row = Reports::Excel::Row.new(i + 1)
          answers_row << questions.map do |question|
            question_answers = response_answers.find_all { |a| a.question_id == question.id }
            question.formatted_answers_for(question_answers, :server_url => excel_data.server_url)
          end
          answers_row << excel_data.metadata.for(response)
          sheet.add_row answers_row.to_a, style: border
        end
      end
    end
  end

  def delayed_job_id
    @delayed_job.id
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
