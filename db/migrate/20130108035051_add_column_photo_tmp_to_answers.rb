class AddColumnPhotoTmpToAnswers < ActiveRecord::Migration
  def change
    add_column :answers, :photo_tmp, :string
  end
end
