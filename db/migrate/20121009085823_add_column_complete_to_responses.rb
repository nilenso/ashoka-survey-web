class AddColumnCompleteToResponses < ActiveRecord::Migration
  def change
    add_column :responses, :complete, :boolean, :default => false
  end
end
