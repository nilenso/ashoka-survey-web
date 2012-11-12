class StoreSessionTokenInResponses < ActiveRecord::Migration
  def up
    add_column :responses, :session_token, :string
  end

  def down
    remove_column :responses, :session_token
  end
end
