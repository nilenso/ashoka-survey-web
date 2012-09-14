class SurveysController < ApplicationController
  before_filter :require_cso_admin, :except => :index

  def index
    unless params[:published].nil?
      @surveys = Survey.where(:published => params[:published]).paginate(:page => params[:page], :per_page => 10)
    else
      @surveys = Survey.paginate(:page => params[:page], :per_page => 10)
    end
  end

  def destroy
    survey = Survey.find(params[:id])
    survey.destroy
    flash[:notice] = t "flash.survey_deleted"
    redirect_to(surveys_path)
  end

  def new
    @survey = Survey.new()
  end

  def create
    @survey = Survey.new(params[:survey])
    @survey.organization_id = session[:user_info][:org_id]

    if @survey.save
      flash[:notice] = t "flash.survey_created"
      redirect_to surveys_build_path(:id => @survey.id)
    else
      render :new
    end
  end

  def build
    @survey = Survey.find(params[:id])
  end

  def publish
    survey = Survey.find(params[:survey_id])
    survey.publish
    flash[:notice] = t "flash.survey_published", :survey_name => survey.name
    redirect_to surveys_path
  end

  def unpublish
    survey = Survey.find(params[:survey_id])
    survey.unpublish
    flash[:notice] = t "flash.survey_unpublished", :survey_name => survey.name
    redirect_to surveys_path
  end

  private

  def require_cso_admin
    role = session[:user_info][:role] if user_currently_logged_in?
    unless role == 'cso_admin'
      flash[:error] = t "flash.not_authorized"
      redirect_to surveys_path
    end
  end
end
