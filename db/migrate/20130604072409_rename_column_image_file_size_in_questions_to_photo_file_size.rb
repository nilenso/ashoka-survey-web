class RenameColumnImageFileSizeInQuestionsToPhotoFileSize < ActiveRecord::Migration
  def change
    rename_column :questions, :image_file_size ,:photo_file_size
  end
end
