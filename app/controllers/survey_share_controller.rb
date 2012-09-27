class SurveyShareController < ApplicationController
  before_filter :require_cso_admin, :only => [:edit, :update]

  def edit
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

  def update
    survey = Survey.find_by_id(params[:survey_id])

    survey.participating_organizations.destroy_all
    survey.survey_users.destroy_all

    user_ids = params[:survey][:user_ids].reject { |user_id| user_id.blank? }
    user_ids.each { |user_id| SurveyUser.create(:survey_id => survey.id, :user_id => user_id)}

    organization_ids = params[:survey][:participating_organization_ids].reject { |org_id| org_id.blank? }
    organization_ids.each { |org_id| ParticipatingOrganization.create(:survey_id => survey.id, :organization_id => org_id) }

    redirect_to surveys_path, :notice => "Survey has been shared"
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
