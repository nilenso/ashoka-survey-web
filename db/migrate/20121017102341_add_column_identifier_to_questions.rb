class AddColumnIdentifierToQuestions < ActiveRecord::Migration
  def change
    add_column :questions, :identifier, :boolean, :default => false
  end
end
