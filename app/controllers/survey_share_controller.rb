class SurveyShareController < ApplicationController
  before_filter :require_cso_admin, :only => :new

  def new
    @survey = Survey.find_by_id(params[:survey_id])
    if @survey.published?
      @users = access_token.get('/api/organization_users').parsed
      @organizations = access_token.get('/api/organizations').parsed.reject do |org|
        org['id'] == @survey.organization_id
      end
    else
      redirect_to surveys_path
      flash[:error] = "Can not share an unpublished survey"
    end
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
