class ResponsesController < ApplicationController
  load_and_authorize_resource :survey
  load_and_authorize_resource :through => :survey

  before_filter :survey_finalized
  before_filter :authorize_public_response, :only => :create
  before_filter :survey_not_expired, :only => :create

  def index
    respond_to do |format|
      @user_names = User.names_for_ids(access_token, @responses.map(&:user_id).uniq)
      @organization_names = Organization.all(access_token)
      @complete_responses = @responses.where(:status => 'complete').order('updated_at')
      format.html do
        @responses = @responses.paginate(:page => params[:page], :per_page => 10).order('created_at DESC, status')
      end
    end
  end

  def generate_excel
    authorize! :generate_excel, @survey
    user_names = User.names_for_ids(access_token, @responses.map(&:user_id).uniq)
    organization_names = Organization.all(access_token)
    filename = @survey.filename_for_excel
    @complete_responses = @responses.where(:status => 'complete').order('updated_at')
    response_ids = @complete_responses.to_a.map(&:id)
    job = Delayed::Job.enqueue(ResponsesExcelJob.new(@survey, response_ids, organization_names,
                                               user_names, server_url, filename), :queue => 'generate_excel')
    render :json => { :excel_path => filename, :id => job.id }
  end

  def create
    response = ResponseDecorator.new(Response.new)
    response.set(params[:survey_id], current_user, current_user_org, session_token)
    response.save
    survey = Survey.find(params[:survey_id])
    response.create_blank_answers
    response.ip_address = request.remote_ip
    response.save(:validate => false)
    redirect_to edit_survey_response_path(:id => response.id), :notice => t("responses.new.response_created")
  end

  def edit
    @survey = Survey.find(params[:survey_id])
    @response = ResponseDecorator.find(params[:id])
    @disabled = false
    @public_response = public_response?
  end

  def show
    @survey = Survey.find(params[:survey_id])
    @response = ResponseDecorator.find(params[:id])
    @disabled = true
    @marker = @response.to_gmaps4rails
    render :edit
  end

  def update
    @response = ResponseDecorator.find(params[:id])
    if @response.update_attributes(params[:response])
      redirect_to :back, :notice => "Successfully updated"
    else
      flash[:error] = "Error"
      render :edit
    end
  end

  def complete
    @response = ResponseDecorator.find(params[:id])
    verify_recaptcha(:model => @response, :attribute => :captcha) if @response.survey_public?
    was_complete = @response.complete?
    answers_attributes = params.try(:[],:response).try(:[], :answers_attributes)
    @response.valid_for?(answers_attributes) ? complete_valid_response : revert_response(was_complete, params[:response])
  end

  def destroy
    response = Response.find(params[:id])
    response.destroy
    flash[:notice] = t "flash.response_deleted"
    redirect_to(survey_responses_path)
  end

  private

  def complete_valid_response
    @response.complete
    success_path = @response.survey_public? && !user_currently_logged_in? ? root_path : survey_responses_path(@response.survey_id)
    redirect_to success_path, :notice => "Successfully updated"
  end

  def revert_response(was_complete, response)
    if was_complete
      @response.complete
    else
      @response.incomplete
    end
    @response.attributes = response
    flash.delete(:recaptcha_error)
    flash[:error] = @response.errors.messages[:captcha] || t("responses.edit.error_saving_response")
    @disabled = false
    render :edit
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
    if public_response?
      raise CanCan::AccessDenied.new("Not authorized!", :create, Response) unless params[:auth_key] == survey.auth_key
    end
  end

  def public_response?
    survey = Survey.find(params[:survey_id])
    survey.public? && !user_currently_logged_in?
  end

  def survey_not_expired
    survey = Survey.find(params[:survey_id])
    if survey.expired?
      flash[:error] = t "flash.response_to_expired_survey", :survey_name => survey.name
      redirect_to surveys_path
    end
  end
end
