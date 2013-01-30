  class AddColumnMandatoryToCategories < ActiveRecord::Migration
  def change
    add_column :categories, :mandatory, :boolean, :default => false
  end
end
