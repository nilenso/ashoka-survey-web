class AddDefaultValueToColumnPrivateInQuestions < ActiveRecord::Migration
  def change
    change_column :questions, :private, :boolean, :default => false
  end
end
