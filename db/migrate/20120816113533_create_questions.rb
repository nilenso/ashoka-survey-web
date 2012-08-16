class CreateQuestions < ActiveRecord::Migration
  def change
    create_table :questions do |t|
      t.text :question
      t.references :survey

      t.timestamps
    end
    add_index :questions, :survey_id
  end
end
