class CreateResponses < ActiveRecord::Migration
  def change
    create_table :responses do |t|
      t.references :survey

      t.timestamps
    end
    add_index :responses, :survey_id
  end
end
