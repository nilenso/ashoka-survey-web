class RemoveAttachmentImageFromQuestions < ActiveRecord::Migration
  def up
    drop_attached_file :questions, :image
  end

  def down
    change_table :questions do |t|
      t.has_attached_file :image
    end
  end
end
