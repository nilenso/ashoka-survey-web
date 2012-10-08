class AddIndexForOrganizationIdToResponses < ActiveRecord::Migration
  def change
    add_index :responses, :organization_id
  end
end
