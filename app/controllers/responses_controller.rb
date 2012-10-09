class ResponsesController < ApplicationController
  load_and_authorize_resource :survey
  load_and_authorize_resource :through => :survey

  before_filter :survey_published

  def index
    @responses = @responses.paginate(:page => params[:page], :per_page => 10)
  end

  def create
    response = ResponseDecorator.new(Response.new)
    survey = Survey.find(params[:survey_id])
    response.survey = survey
    response.user_id = current_user
    response.organization_id = current_user_org
    survey.questions.each { |question| response.answers << Answer.new(:question_id => question.id) }
    response.save(:validate => false)
    redirect_to edit_survey_response_path(:id => response.id, :survey_id => survey.id)
  end

  def edit
    @survey = Survey.find(params[:survey_id])
    @response = ResponseDecorator.find(params[:id])
  end

  def update
    @response = ResponseDecorator.find(params[:id])
    if @response.update_attributes(params[:response])
      redirect_to survey_responses_path, :notice => "Successfully updated"
    else
      flash[:error] = "Error"
      render :edit
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
