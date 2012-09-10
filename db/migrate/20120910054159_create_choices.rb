class CreateChoices < ActiveRecord::Migration
  def change
    create_table :choices do |t|
      t.string :content
      t.references :answer

      t.timestamps
    end
    add_index :choices, :answer_id
  end
end
