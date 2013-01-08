class AddColumnImageTmpToQuestions < ActiveRecord::Migration
  def change
    add_column :questions, :image_tmp, :string
  end
end
