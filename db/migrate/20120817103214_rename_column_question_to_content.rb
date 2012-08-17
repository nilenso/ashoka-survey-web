class RenameColumnQuestionToContent < ActiveRecord::Migration
  def up
    rename_column :questions, :question, :content
  end

  def down
    rename_column :questions, :content, :question
  end
end
