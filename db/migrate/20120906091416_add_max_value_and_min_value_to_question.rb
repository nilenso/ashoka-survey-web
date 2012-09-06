class AddMaxValueAndMinValueToQuestion < ActiveRecord::Migration
  def change
    add_column :questions, :max_value, :integer
    add_column :questions, :min_value, :integer
  end
end
