class AddColumnPublishedToSurveys < ActiveRecord::Migration
  def change
    add_column :surveys, :published, :boolean, :default => :false
  end
end
