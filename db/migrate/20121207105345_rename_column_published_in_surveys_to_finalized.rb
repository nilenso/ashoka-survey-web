class RenameColumnPublishedInSurveysToFinalized < ActiveRecord::Migration
  def up
    rename_column :surveys, :published, :finalized
  end

  def down
    rename_column :surveys, :finalized, :published
  end
end
