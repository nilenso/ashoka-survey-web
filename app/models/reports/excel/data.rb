class Reports::Excel::Data
  attr_reader :survey, :responses, :server_url, :file_name

  def initialize(survey, responses, server_url, access_token, options={})
    @survey = survey
    @responses = responses
    @access_token = access_token
    @file_name = survey.filename_for_excel
    @filter_private_questions = options[:filter_private_questions]
  end

  def questions
    questions = survey.questions_in_order.map(&:reporter)
    if @filter_private_questions
      questions.reject(&:private?)
    else
      questions
    end
  end

  def user_name_for(id)
    @user_names ||= User.names_for_ids(@access_token, @responses.map(&:user_id).uniq)
    @user_names[id]
  end

  def organization_name_for(id)
    @organizations ||= Organization.all(@access_token)
    organization = @organizations.find { |o| o.id == id }
    organization ? organization.name : ""
  end
end
