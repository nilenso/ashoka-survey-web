class AddMobileIdColumnToResponses < ActiveRecord::Migration
  def change
    add_column :responses, :mobile_id, :string
  end
end
