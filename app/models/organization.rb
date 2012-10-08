class Organization
  attr_reader :id, :name

	def initialize(id, name)
    @id = id
    @name = name
  end

  def self.all(access_token, options={})
    if access_token
      organizations = access_token.get('/api/organizations').parsed.map { |org_json| self.json_to_organization(org_json) }
      organizations.reject { |org| org.id == options[:except] }
    end
  end

  def self.json_to_organization(org_json)
    Organization.new(org_json['id'], org_json['name'])
  end

  def self.users(client, organization_id)
    User.find_by_organization(client, organization_id)
  end
end