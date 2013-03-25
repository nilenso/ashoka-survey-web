class AddDefaultValueForColumnBlankInResponses < ActiveRecord::Migration
  def up
    change_column :responses, :blank, :boolean, :default => false
  end

  def down
    change_column :responses, :blank, :boolean, :default => nil
  end
end
