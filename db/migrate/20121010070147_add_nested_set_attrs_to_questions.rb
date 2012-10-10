class AddNestedSetAttrsToQuestions < ActiveRecord::Migration
  def change
    add_column :questions, :lft, :integer
    add_column :questions, :rgt, :integer
    add_column :questions, :parent_id, :integer
  end
end
