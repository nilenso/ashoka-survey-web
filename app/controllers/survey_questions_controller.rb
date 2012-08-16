class SurveyQuestionsController < ApplicationController

  def create
    @survey_question = SurveyQuestion.new(params[:survey_question])

    if @survey_question.save
      redirect_to root_path
      flash[:notice] = "Question successfully created"
    end
  end
end
