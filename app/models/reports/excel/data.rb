class Reports::Excel::Data
  attr_reader :survey, :responses

  def initialize(survey, responses, access_token)
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
    @organizations.find { |o| o.id == id }.name
  end
end
