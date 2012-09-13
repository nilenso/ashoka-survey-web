class AddColumnOrganizationIdToSurveys < ActiveRecord::Migration
  def change
    add_column :surveys, :organization_id, :integer
  end
end
