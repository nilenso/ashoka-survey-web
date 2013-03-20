class AddRecordIdToAnswers < ActiveRecord::Migration
  def change
    add_column :answers, :record_id, :integer
  end
end
