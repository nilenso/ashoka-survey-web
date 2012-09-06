class ResponsesController < ApplicationController
  def new
    @survey = Survey.find(params[:survey_id])
    @response = Response.new
    @survey.questions.sort {|a,b| a.order_number <=> b.order_number}
    @survey.questions.each do |question|
      answer = Answer.new
      @response.answers << answer
      answer.question = question
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
