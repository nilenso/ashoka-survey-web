class AddColumnResponseRefToAnswer < ActiveRecord::Migration
  def change
    add_column :answers, :response_id, :integer
  end
end
