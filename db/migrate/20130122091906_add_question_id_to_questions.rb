class AddQuestionIdToQuestions < ActiveRecord::Migration
  def change
    add_column :questions, :multi_record_question_id, :integer
  end
end
