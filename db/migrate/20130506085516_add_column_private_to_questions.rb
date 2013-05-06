class AddColumnPrivateToQuestions < ActiveRecord::Migration
  def change
    add_column :questions, :private, :boolean
  end
end
