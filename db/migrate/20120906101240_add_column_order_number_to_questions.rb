class AddColumnOrderNumberToQuestions < ActiveRecord::Migration
  def change
    add_column :questions, :order_number, :integer
  end
end
