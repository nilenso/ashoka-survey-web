class RemoveMutiRecordQuestionIdFromQuestions < ActiveRecord::Migration
  def up
    remove_column :questions, :multi_record_question_id
  end

  def down
    add_column :questions, :multi_record_question_id, :integer
  end
end
