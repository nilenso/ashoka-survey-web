class AddThankYouMessageToSurvey < ActiveRecord::Migration
  def change
    add_column :surveys, :thank_you_message, :text
  end
end
