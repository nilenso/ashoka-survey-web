class ResponsesController < ApplicationController
  before_filter :survey_published
  before_filter :require_login_of_same_org_user
  def new
    @survey = Survey.find(params[:survey_id])
    @response = Response.new
    @survey.questions.each do |question|
      answer = Answer.new
      @response.answers << answer
      answer.question = question
    end
  end

  def index
    if session[:user_info][:role] == 'user'
      @responses = Response.where(:survey_id => params[:survey_id], :user_id => current_user).paginate(:page => params[:page], :per_page => 10)
    else
      @responses = Response.where(:survey_id => params[:survey_id]).paginate(:page => params[:page], :per_page => 10)
    end
  end

  def create
    @response = Response.new(params[:response])
    @response.survey = Survey.find(params[:survey_id])
    @survey = @response.survey
    @response.user_id = current_user
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

  def require_login_of_same_org_user
    survey = Survey.find(params[:survey_id])
    if current_user.nil? || current_user_org != survey.organization_id
      flash[:error] = t "flash.not_authorized"
      redirect_to root_path
    end
  end
end
