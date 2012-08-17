class ResponsesController < ApplicationController
  def new
    @survey = Survey.find(params[:survey_id])
    @questions = @survey.questions
    @response = Response.new
  end
end
