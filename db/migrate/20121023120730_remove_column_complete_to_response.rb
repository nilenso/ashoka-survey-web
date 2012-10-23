class RemoveColumnCompleteToResponse < ActiveRecord::Migration
  def up
    remove_column :responses, :complete
  end

  def down
    add_column :responses, :complete, :boolean
  end
end
