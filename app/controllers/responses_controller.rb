class ResponsesController < ApplicationController
  def new
    @survey = Survey.find(params[:survey_id])
    @response = Response.new
    @survey.questions.each do |question|
      answer = Answer.new
      @response.answers << answer
      answer.question = question
    end

    def create
      @response = Response.new(params[:response])
      @response.survey = Survey.find(params[:survey_id])
      if @response.save
        redirect_to root_path
      end
    end
  end
end
