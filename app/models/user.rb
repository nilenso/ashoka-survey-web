class User
  attr_reader :id, :name, :role

  def initialize(id, name, role)
    @id = id
    @name = name
    @role = role
  end

  def self.find_by_organization(client, organization_id)
    users = []
    client.get("/api/organizations/#{organization_id}/users").parsed.each { |user_json|
       users.push (self.json_to_user(user_json))
    }
    users
  end

  def self.json_to_user(user_json)
    User.new(user_json['id'], user_json['name'], user_json['role'])
  end
end
