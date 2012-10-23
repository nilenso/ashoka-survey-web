class ResponsesController < ApplicationController
  load_and_authorize_resource :survey
  load_and_authorize_resource :through => :survey

  before_filter :survey_published
  
  def index
    @responses = @responses.paginate(:page => params[:page], :per_page => 10)
  end

  def create
    response = ResponseDecorator.new(Response.new)
    response.set(params[:survey_id], current_user, current_user_org)
    survey = Survey.find(params[:survey_id])
    survey.questions.each { |question| response.answers << Answer.new(:question_id => question.id) }
    response.save(:validate => false)
    redirect_to edit_survey_response_path(:id => response.id), :notice => t("responses.new.response_created")
  end

  def edit
    @survey = Survey.find(params[:survey_id])
    @response = ResponseDecorator.find(params[:id])
    sort_questions_by_order_number(@response)
  end

  def update
    @response = ResponseDecorator.find(params[:id])
    if @response.update_attributes(params[:response])
      redirect_to survey_responses_path, :notice => "Successfully updated"
    else
      flash[:error] = "Error"
      sort_questions_by_order_number(@response)
      render :edit
    end
  end

  def complete
    @response = ResponseDecorator.find(params[:id])
    @response.validating
    if @response.update_attributes(params[:response])
      @response.complete
      redirect_to survey_responses_path(@response.survey_id), :notice => "Successfully updated"
    else
      @response.incomplete
      sort_questions_by_order_number(@response)
      flash[:error] = "Error"
      render :edit
    end
  end

  def destroy
    response = Response.find(params[:id])
    response.destroy
    flash[:notice] = t "flash.response_deleted"
    redirect_to(survey_responses_path)
  end

  private

  def sort_questions_by_order_number(response)
    question_ids_in_order = response.survey.question_ids_in_order
    response.answers.sort_by! { |answer| question_ids_in_order.index(answer.question.id) }
  end

  def survey_published
    survey = Survey.find(params[:survey_id])
    unless survey.published
      flash[:error] = t "flash.reponse_to_unpublished_survey", :survey_name => survey.name
      redirect_to surveys_path
    end
  end
end
