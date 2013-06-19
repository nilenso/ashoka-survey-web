class AddMarkedForDeletionFlagToSurvey < ActiveRecord::Migration
  def change
    add_column :surveys, :marked_for_deletion, :boolean, :default => false
  end
end
