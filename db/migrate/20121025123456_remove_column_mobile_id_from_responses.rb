class RemoveColumnMobileIdFromResponses < ActiveRecord::Migration
  def up
    remove_column :responses, :mobile_id
  end

  def down
    add_column :responses, :mobile_id, :integer
  end
end
