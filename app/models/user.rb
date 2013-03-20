class User
  attr_reader :id, :name, :role

  def initialize(id, name, role)
    @id = id
    @name = name
    @role = role
  end

  def self.find_by_organization(client, organization_id)
    client.get("/api/organizations/#{organization_id}/users").parsed.inject([]) { |users, user_json|
       users.push(json_to_user(user_json))
    }
  end

  def self.json_to_user(user_json)
    User.new(user_json['id'], user_json['name'], user_json['role'])
  end

  def self.names_for_ids(client, user_ids)
    return {} if not client
    users = client.get("/api/users/names_for_ids", :params => {:user_ids => user_ids.to_json}).parsed
    users.inject({}) do |hash, user|
      hash[user['id']] = user['name']
      hash
    end
  end

  def self.exists?(client, user_ids)
    user_exists = client.get("/api/users/validate_users", :params => {:user_ids => user_ids.to_json})
    user_exists.parsed
  end

  def publishable?
    role == "field_agent" || role == "supervisor"
  end
end
