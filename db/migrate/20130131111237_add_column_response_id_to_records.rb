class AddColumnResponseIdToRecords < ActiveRecord::Migration
  def change
    add_column :records, :response_id, :integer
  end
end
