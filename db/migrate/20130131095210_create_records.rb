class CreateRecords < ActiveRecord::Migration
  def change
    create_table :records do |t|
      t.integer :category_id
      t.timestamps
    end
  end
end
