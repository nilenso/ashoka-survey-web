class Reports::Excel::Metadata
  def initialize(responses, access_token)
    @responses = responses
    @access_token = access_token
  end

  def headers
    ["Added By", "Organization", "Last updated at", "Address", "IP Address", "State"]
  end

  def for(response)
    [user_name_for(response.user_id), organization_name_for(response.organization_id), response.last_update,
      response.location, response.ip_address, response.state]
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
