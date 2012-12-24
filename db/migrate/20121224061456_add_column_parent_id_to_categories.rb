class AddColumnParentIdToCategories < ActiveRecord::Migration
  def change
    add_column :categories, :parent_id, :integer
  end
end
