class Reports::Excel::Data
  attr_reader :survey, :responses, :server_url, :file_name, :questions, :metadata

  def initialize(survey, questions, responses, server_url, access_token)
    @survey = survey
    @responses = responses
    @access_token = access_token
    @file_name = survey.filename_for_excel
    @questions = questions
    @metadata = Reports::Excel::Metadata.new(@responses, access_token)
  end
end
