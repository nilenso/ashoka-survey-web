class RemoveImageTmpColumnFromQuestion < ActiveRecord::Migration
  def up
    remove_column :questions, :image_tmp
  end

  def down
    add_column :questions, :image_tmp, :string
  end
end
