class RemoveSharedOrgIdsFromSurvey < ActiveRecord::Migration
  def up
  	remove_column :surveys, :shared_org_ids
  end

  def down
  	add_column :surveys, :shared_org_ids, :string
  end
end
