class RenameColumnOwnerOrgIdInSurveysToOrganizationId < ActiveRecord::Migration
  def up
  	rename_column :surveys, :organization.id, :organization_id
  end

  def down
  	rename_column :surveys, :organization_id, :organization.id
  end
end
