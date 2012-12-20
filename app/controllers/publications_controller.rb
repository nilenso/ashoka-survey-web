class PublicationsController < ApplicationController
  before_filter :require_finalized_survey
  before_filter :require_organizations_or_users_to_be_selected, :only => [:update]

  def edit
    @survey = Survey.find(params[:survey_id])
    authorize! :edit, @survey
    field_agents = @survey.users_for_organization(access_token, current_user_org)
    @published_users = field_agents[:published]
    @unpublished_users = field_agents[:unpublished]

    partitioned_organizations = @survey.partitioned_organizations(access_token)
    @shared_organizations = partitioned_organizations[:participating]
    @unshared_organizations = partitioned_organizations[:not_participating]
  end

  def update
    survey = Survey.find(params[:survey_id])
    authorize! :update, survey
    survey.update_attributes({:expiry_date => params[:survey][:expiry_date]})
    survey.update_attributes({:public => params[:survey][:public]})
    if survey.save
      survey.publish_to_users(@users) if @users.present?
      survey.share_with_organizations(@organizations) if @organizations.present?
      flash[:notice] = t "flash.survey_published", :survey_name => survey.name
      redirect_to surveys_path
    else
      flash[:error] = survey.errors.full_messages.join(', ')
      redirect_to(:back)
    end
  end

  private

  def require_finalized_survey
    survey = Survey.find(params[:survey_id])
    unless survey.finalized?
      redirect_to surveys_path
      flash[:error] = t "flash.publish_draft_survey"
    end
  end

  def require_organizations_or_users_to_be_selected
    survey = Survey.find(params[:survey_id])
    return true if survey.published? || params[:survey][:public]
    @users = Sanitizer.clean_params(params[:survey][:user_ids])
    @organizations = Sanitizer.clean_params(params[:survey][:participating_organization_ids])
    if @users.blank? && @organizations.blank?
      flash[:error] = t "flash.users_and_organizations_blank"
      redirect_to(:back)
    end
  end
end
