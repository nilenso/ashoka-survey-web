class AddColumnSharedOrgIdsToSurveys < ActiveRecord::Migration
  def change
    add_column :surveys, :shared_org_ids, :string
  end
end
