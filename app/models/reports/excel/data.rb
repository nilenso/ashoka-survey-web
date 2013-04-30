class Reports::Excel::Data
  attr_reader :survey, :responses, :server_url

  def initialize(survey, responses, server_url, access_token)
    @survey = survey
    @responses = responses
    @access_token = access_token
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

  def file_name
    @file_name ||= survey.filename_for_excel
  end
end
