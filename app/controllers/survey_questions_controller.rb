class SurveyQuestionsController < ApplicationController
  def new
    @question = SurveyQuestion.new
  end
end
