class AddAttachmentPhotoToAnswers < ActiveRecord::Migration
  def self.up
    change_table :answers do |t|
      t.has_attached_file :photo
    end
  end

  def self.down
    drop_attached_file :answers, :photo
  end
end
