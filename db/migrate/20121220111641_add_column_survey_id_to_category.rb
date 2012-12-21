class AddColumnSurveyIdToCategory < ActiveRecord::Migration
  def change
    add_column :categories, :survey_id, :integer
  end
end
