class CreateSurveys < ActiveRecord::Migration
  def change
    create_table :surveys do |t|
      t.string :name
      t.date :expiry_date
      t.text :description

      t.timestamps
    end
  end
end
