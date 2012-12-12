class AddColumnPublishedOnToSurveys < ActiveRecord::Migration
  def change
    add_column :surveys, :published_on, :date
  end
end
