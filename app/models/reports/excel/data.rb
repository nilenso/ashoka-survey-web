class Reports::Excel::Data
  def initialize(responses, access_token)
    @responses = responses
    @access_token = access_token
  end

  def user_name_for(id)
    @user_names ||= User.names_for_ids(@access_token, @responses.select(&:user_id).uniq.map(&:user_id))
    @user_names[id]
  end

  def organization_name_for(id)
    @organizations ||= Organization.all(@access_token)
    @organizations.find { |o| o.id == id }.name
  end

  def responses
    @responses.completed.earliest_first
  end
end
