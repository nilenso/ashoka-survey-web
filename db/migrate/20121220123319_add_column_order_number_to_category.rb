class AddColumnOrderNumberToCategory < ActiveRecord::Migration
  def change
    add_column :categories, :order_number, :integer
  end
end
