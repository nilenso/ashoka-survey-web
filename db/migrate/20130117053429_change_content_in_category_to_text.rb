class ChangeContentInCategoryToText < ActiveRecord::Migration
  def up
    change_table :categories do |t|
      t.change :content, :text
    end
  end

  def down
    change_table :categories do |t|
      t.change :content, :string
    end
  end
end
