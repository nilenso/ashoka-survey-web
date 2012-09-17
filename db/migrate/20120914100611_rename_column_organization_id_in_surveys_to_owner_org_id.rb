class RenameColumnOrganizationIdInSurveysToOwnerOrgId < ActiveRecord::Migration
  def up
  	rename_column :surveys, :organization_id, :organization_id
  end

  def down
  	rename_column :surveys, :organization_id, :organization_id
  end
end
