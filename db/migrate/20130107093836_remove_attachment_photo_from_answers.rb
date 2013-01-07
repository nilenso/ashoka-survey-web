class RemoveAttachmentPhotoFromAnswers < ActiveRecord::Migration
  def up
    drop_attached_file :answers, :photo
  end

  def down
    change_table :answers do |t|
      t.has_attached_file :photo
    end
  end
end
