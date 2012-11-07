class AddColumnPublicToSurveys < ActiveRecord::Migration
  def change
    add_column :surveys, :public, :boolean, :default => false
  end
end
