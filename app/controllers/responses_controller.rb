class ResponsesController < ApplicationController
  load_and_authorize_resource :survey
  load_and_authorize_resource :through => :survey

  before_filter :survey_finalized
  before_filter :authorize_public_response, :only => :create
  before_filter :survey_not_expired, :only => :create

  after_filter :only => [:destroy] { send_to_mixpanel("Response deleted", {:survey => @response.survey.name}) if @response.present? }

  def generate_excel
    authorize! :generate_excel, @survey
    @responses = Reports::Excel::Responses.new(@responses).build(params[:date_range]).all
    @questions = Reports::Excel::Questions.new(@survey, current_ability).build(:disable_filtering => params[:disable_filtering]).all
    @metadata = Reports::Excel::Metadata.new(@responses, access_token, :disable_filtering => params[:disable_filtering])
    @data = Reports::Excel::Data.new(@survey, @questions, @responses, server_url, @metadata)
    job = Reports::Excel::Job.new(@data)
    job.start
    render :json => { :excel_path => @data.file_name, :id => job.delayed_job_id, :password => @data.password }
  end

  def create
    response = ResponseDecorator.new(Response.new(:blank => true))
    response.set(params[:survey_id], current_user, current_user_org, session_token)
    response.save
    survey = Survey.find(params[:survey_id])
    response.create_blank_answers
    response.ip_address = request.remote_ip
    response.save(:validate => false)
    redirect_to edit_survey_response_path(:id => response.id)
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
    @response.update_column(:blank, false)
    if @response.update_attributes(params[:response])
      send_to_mixpanel("Response updated", { :survey => @response.survey.name })
      redirect_to :back, :notice => "Successfully updated"
    else
      flash[:error] = "Error"
      render :edit
    end
  end

  def complete
    @response = ResponseDecorator.find(params[:id])
    @response.update_column(:blank, false)
    was_complete = @response.complete?
    answers_attributes = params.try(:[],:response).try(:[], :answers_attributes)
    if @response.valid_for?(answers_attributes)
      send_to_mixpanel("Response completed", { :survey => @response.survey.name })
      complete_valid_response
    else
      revert_response(was_complete, params[:response])
    end
  end

  def destroy
    response = Response.find(params[:id])
    response.destroy
    flash[:notice] = t "flash.response_deleted"
    redirect_to(survey_responses_path)
  end

  private

  def complete_valid_response
    @response.update_column('status', 'complete')
    if @response.survey_public? && !user_currently_logged_in?
      @public_response = public_response?
      @survey = @response.survey.decorate
      render "thank_you"
    else
      redirect_to survey_responses_path(@response.survey_id), :notice => "Successfully updated"
    end
  end

  def revert_response(was_complete, response)
    if was_complete
      @response.complete
    else
      @response.incomplete
    end
    @response.attributes = response
    flash[:error] = t("responses.edit.error_saving_response")
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
