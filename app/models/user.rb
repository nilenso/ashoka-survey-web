class User
  attr_reader :id, :name, :role, :email

  def initialize(id, name, role, email)
    @id = id
    @name = name
    @role = role
    @email = email
  end

  def self.find_by_organization(client, organization_id)
    client.get("/api/organizations/#{organization_id}/users").parsed.inject([]) { |users, user_json|
       users.push(json_to_user(user_json))
    }
  end

  def self.users_for_ids(client, user_ids)
    return {} if not client
    users = client.get("/api/users/users_for_ids", :params => {:user_ids => user_ids.to_json}).parsed
    users.inject([]) do |array, user_json|
      array << json_to_user(user_json)
      array
    end
  end

  def self.exists?(client, user_ids)
    user_exists = client.get("/api/users/validate_users", :params => {:user_ids => user_ids.to_json})
    user_exists.parsed
  end

  def publishable?
    role == "field_agent" || role == "supervisor"
  end

  private

  def self.json_to_user(user_json)
    User.new(user_json['id'], user_json['name'], user_json['role'], user_json['email'])
  end
end
