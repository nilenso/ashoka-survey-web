class ResponsesController < ApplicationController
  def new
    @survey = Survey.find(params[:survey_id])
    @answers = @survey.questions.map(&:answers)
    @response = Response.new
  end
end
