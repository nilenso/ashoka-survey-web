class Organization
  attr_reader :id, :name

  def initialize(id, name)
    @id = id
    @name = name
  end

  def self.all(access_token, options={})
    return unless access_token
    organizations = access_token.get('/api/organizations').parsed.map { |org_json| json_to_organization(org_json) }
    organizations.reject { |org| org.id == options[:except] }
  end

  def self.json_to_organization(org_json)
    Organization.new(org_json['id'], org_json['name'])
  end

  def self.users(client, organization_id)
    if organization_id
      User.find_by_organization(client, organization_id)
    else
      []
    end
  end

  def self.publishable_users(client, organization_id)
    users(client, organization_id).select { |user| user.publishable? }
  end

  def self.exists?(client, org_ids)
    org_exists = client.get("/api/organizations/validate_orgs", :params => {:org_ids => org_ids.to_json})
    org_exists.parsed
  end
end
