class CreateParticipatingOrganizations < ActiveRecord::Migration
  def change
    create_table :participating_organizations do |t|
      t.integer :survey_id
      t.integer :organization_id

      t.timestamps
    end
  end
end
