class AddColumnMobileIdToResponses < ActiveRecord::Migration
  def change
    add_column :responses, :mobile_id, :integer
  end
end
