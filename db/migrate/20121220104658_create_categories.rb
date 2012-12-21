class CreateCategories < ActiveRecord::Migration
  def change
    create_table :categories do |t|
      t.references :category
      t.string :content

      t.timestamps
    end
    add_index :categories, :category_id
  end
end
