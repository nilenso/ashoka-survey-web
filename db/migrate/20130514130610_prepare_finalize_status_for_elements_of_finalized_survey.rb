class PrepareFinalizeStatusForElementsOfFinalizedSurvey < ActiveRecord::Migration
  def up
    finalized_survey_ids = Survey.where(:finalized => true).select('id')
    questions = Question.unscoped.where("survey_id IN (?)", finalized_survey_ids)
    categories = Category.unscoped.where("survey_id IN (?)", finalized_survey_ids)
    options = Option.unscoped.joins(:question).where("questions.survey_id in (?)", finalized_survey_ids)
    [questions, categories, options].each { |elements| elements.update_all("finalized = true") }
  end

  def down
  end
end
