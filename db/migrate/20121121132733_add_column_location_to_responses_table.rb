class AddColumnLocationToResponsesTable < ActiveRecord::Migration
  def change
    add_column :responses, :location, :string
  end
end
