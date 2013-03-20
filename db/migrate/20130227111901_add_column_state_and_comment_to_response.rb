class AddColumnStateAndCommentToResponse < ActiveRecord::Migration
  def change
    add_column :responses, :state, :string
    add_column :responses, :comment, :text
  end
end
