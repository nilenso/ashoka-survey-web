class CreateSurveyQuestions < ActiveRecord::Migration
  def change
    create_table :survey_questions do |t|
      t.text :question
      t.references :survey

      t.timestamps
    end
    add_index :survey_questions, :survey_id
  end
end
