class AddColumnArchivedToSurveys < ActiveRecord::Migration
  def change
    add_column :surveys, :archived, :boolean, :default => false
  end
end
