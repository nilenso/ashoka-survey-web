class AddColumnTmpAndSecureTokenToPhoto < ActiveRecord::Migration
  def change
    add_column :photos, :tmp, :string
    add_column :photos, :secure_token, :string
  end
end
