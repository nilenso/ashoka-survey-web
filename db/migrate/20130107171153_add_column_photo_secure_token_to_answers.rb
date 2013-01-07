class AddColumnPhotoSecureTokenToAnswers < ActiveRecord::Migration
  def change
    add_column :answers, :photo_secure_token, :string
  end
end
