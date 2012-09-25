class AddUserIdColumnToResponse < ActiveRecord::Migration
  def change
    add_column :responses, :user_id, :integer
  end
end
