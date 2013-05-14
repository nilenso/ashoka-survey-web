class AddFinalizedToOptionsCategoriesAndQuestions < ActiveRecord::Migration
  def change
    add_column :questions, :finalized, :boolean, :default => false
    add_column :options, :finalized, :boolean, :default => false
    add_column :categories, :finalized, :boolean, :default => false
  end
end
