class ResponsesController < ApplicationController
  load_and_authorize_resource :survey
  load_and_authorize_resource :through => :survey

  before_filter :survey_finalized
  before_filter :authorize_public_response, :only => :create
  before_filter :survey_not_expired, :only => :create

  def index
    respond_to do |format|
      @user_names = User.names_for_ids(access_token, @responses.map(&:user_id).uniq)
      format.html do
        @responses = @responses.paginate(:page => params[:page], :per_page => 10)
      end
      @complete_responses = @responses.select { |response| response.complete? }
      format.xlsx do
        response.headers["Content-Disposition"] = "attachment; filename=\"#{@complete_responses.first.try(:filename_for_excel)}\""
      end
    end
  end

  def create
    response = ResponseDecorator.new(Response.new)
    response.set(params[:survey_id], current_user, current_user_org, session_token)
    survey = Survey.find(params[:survey_id])
    response.answers = survey.questions.collect { |question| Answer.new(:question_id => question.id) }
    response.ip_address = request.remote_ip
    response.save(:validate => false)
    redirect_to edit_survey_response_path(:id => response.id), :notice => t("responses.new.response_created")
  end

  def edit
    @survey = Survey.find(params[:survey_id])
    @response = ResponseDecorator.find(params[:id])
    sort_questions_by_order_number(@response)
    @disabled = false
  end

  def show
    @survey = Survey.find(params[:survey_id])
    @response = ResponseDecorator.find(params[:id])
    sort_questions_by_order_number(@response)
    @disabled = true
    @marker = @response.to_gmaps4rails
    render :edit
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
    verify_recaptcha(:model => @response, :attribute => :captcha) if @response.survey_public?
    if @response.errors.empty? && @response.update_answers(params.try(:[],:response).try(:[], :answers_attributes))
      @response.complete
      redirect_to survey_responses_path(@response.survey_id), :notice => "Successfully updated"
    else
      @response.incomplete
      sort_questions_by_order_number(@response)
      @response.attributes = params[:response]
      flash.delete(:recaptcha_error)
      flash[:error] = @response.errors.messages[:captcha] || t("responses.edit.error_saving_response")
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

  def survey_finalized
    survey = Survey.find(params[:survey_id])
    unless survey.finalized
      flash[:error] = t "flash.response_to_draft_survey", :survey_name => survey.name
      redirect_to surveys_path
    end
  end

  def authorize_public_response
    survey = Survey.find(params[:survey_id])
    if survey.public? && !user_currently_logged_in?
      raise CanCan::AccessDenied.new("Not authorized!", :create, Response) unless params[:auth_key] == survey.auth_key
    end
  end

  def survey_not_expired
    survey = Survey.find(params[:survey_id])
    if survey.expired?
      flash[:error] = t "flash.response_to_expired_survey", :survey_name => survey.name
      redirect_to surveys_path
    end
  end
end
