class AddColumnPhotoSecureTokenToQuestions < ActiveRecord::Migration
  def change
    add_column :questions, :photo_secure_token, :string
  end
end
