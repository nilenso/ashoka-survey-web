class UseOptionIdInsteadOfContentInChoices < ActiveRecord::Migration
  def up
    remove_column :choices, :content
    add_column :choices, :option_id, :integer
  end

  def down
    add_column :choices, :content, :string
    remove_column :choices, :option_id
  end
end
