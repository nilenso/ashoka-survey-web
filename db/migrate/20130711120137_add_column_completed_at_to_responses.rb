class AddColumnCompletedAtToResponses < ActiveRecord::Migration
  def change
    add_column :responses, :completed_at, :datetime
  end
end
