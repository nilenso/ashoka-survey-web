class AddColumnsToQuestion < ActiveRecord::Migration
  def change
  	add_column :questions, :mandatory, :boolean, :default => false
  	add_column :questions, :image, :string
  	add_column :questions, :max_length, :integer
  end
end
