class ChangeBlankFromResponseToAnswersPresent < ActiveRecord::Migration
  def change
    rename_column :responses, :blank, :answers_present
  end
end
