class SurveysController < ApplicationController
  before_filter :require_cso_admin, :except => [:index, :build]
  before_filter :survey_unpublished, :only => [:build]
  def index
    filter = {}
    if !user_currently_logged_in?
      filter[:name] = 'foo'
      #temporary fix for 'public' surveys
    else
      filter[:organization_id] = session[:user_info][:org_id]
      filter[:published] = params[:published] unless params[:published].nil?
      if session[:user_info][:role] == 'user'
        filter[:published] = true
      end
    end
    @surveys = Survey.where(filter).paginate(:page => params[:page], :per_page => 10)
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
    redirect_to(:back)
  end

  def share
    @survey = Survey.find(params[:survey_id])
    @organizations = session[:user_info][:organizations]
    @organizations.select!{ |org| org[:id] != @survey.organization_id }
  end

  def update_shared_orgs
    @survey = Survey.find(params[:survey_id])
    @survey.shared_org_ids = params[:survey][:shared_org_ids].delete_if { |s| s.blank? }
    @survey.save
    flash[:notice] = "Successfully shared..."
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

  def survey_unpublished
    survey = Survey.find(params[:id])
    if survey.published?
      flash[:error] = t "flash.edit_published_survey"
      redirect_to root_path
    end
  end
end
