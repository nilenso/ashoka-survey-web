class AddColumnAuthKeyToSurveys < ActiveRecord::Migration
  def change
    add_column :surveys, :auth_key, :string
  end
end
