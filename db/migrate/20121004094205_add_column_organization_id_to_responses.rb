class AddColumnOrganizationIdToResponses < ActiveRecord::Migration
  def change
    add_column :responses, :organization_id, :integer
  end
end
