class Organization
  attr_reader :id, :name

	def initialize(id, name)
    @id = id
    @name = name
  end

  def self.all_except(access_token, organization_id)
    organizations = []
    access_token.get('/api/organizations').parsed.each do |org_json|
      organizations.push self.json_to_organization(org_json)
    end
    organizations.reject { |org| org.id == organization_id }
  end

  def self.json_to_organization(org_json)
    Organization.new(org_json['id'], org_json['name'])
  end

  def self.users(client, organization_id)
    User.find_by_organization(client, organization_id)
  end
end