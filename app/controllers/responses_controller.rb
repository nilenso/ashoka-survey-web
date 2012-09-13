class ResponsesController < ApplicationController
  before_filter :survey_published

  def new
    @survey = Survey.find(params[:survey_id])
    @response = Response.new
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

  private

  def survey_published
    survey = Survey.find(params[:survey_id])
    unless survey.published
      flash[:error] = t "flash.reponse_to_unpublished_survey", :survey_name => survey.name
      redirect_to surveys_path
    end
  end
end
