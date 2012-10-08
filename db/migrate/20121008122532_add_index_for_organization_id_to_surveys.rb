class AddIndexForOrganizationIdToSurveys < ActiveRecord::Migration
  def change
    add_index :surveys, :organization_id
  end
end
