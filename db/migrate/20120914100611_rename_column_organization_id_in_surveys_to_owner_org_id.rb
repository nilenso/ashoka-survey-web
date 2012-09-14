class RenameColumnOrganizationIdInSurveysToOwnerOrgId < ActiveRecord::Migration
  def up
  	rename_column :surveys, :organization_id, :owner_org_id
  end

  def down
  	rename_column :surveys, :owner_org_id, :organization_id
  end
end
