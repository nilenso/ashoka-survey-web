class ResponsesController < ApplicationController
  def new
    @survey = Survey.find(params[:survey_id])
    @response = Response.new
    @survey.questions.each do |question|
      answer = Answer.new
      @response.answers << answer
      answer.question = question
      answer.choices << Choice.new if question.is_a?(MultiChoiceQuestion)
    end
  end

  def create
    @response = Response.new(params[:response])
    @response.survey = Survey.find(params[:survey_id])
    @survey = @response.survey
    if @response.save
      redirect_to root_path, :notice => t("responses.new.response_saved")
    else 
      render :new
    end
  end
end
