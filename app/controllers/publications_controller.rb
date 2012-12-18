class PublicationsController < ApplicationController
  # load_and_authorize_resource

  before_filter :require_finalized_survey
  before_filter :require_organizations_or_users_to_be_selected, :only => [:update]

  def edit
    @survey = Survey.find(params[:survey_id])
    users = Organization.users(access_token, current_user_org).reject { |user| user.id == current_user }
    @shared_users = @survey.users_for_organization(access_token, current_user_org)
    @unshared_users = users.reject { |user| @shared_users.map(&:id).include?(user.id) }
    organizations = Organization.all(access_token, :except => @survey.organization_id)
    @shared_organizations, @unshared_organizations = organizations.partition do |organization|
      @survey.participating_organization_ids.include? organization.id
    end
  end

  def update
    survey = Survey.find(params[:survey_id])
    users = Sanitizer.clean_params(params[:survey][:user_ids])
    if users.present?
      survey.publish_to_users(users)
    end

    organizations = Sanitizer.clean_params(params[:survey][:participating_organization_ids])
    if organizations.present?
      survey.share_with_organizations(organizations)
    end

    flash[:notice] = t "flash.survey_published", :survey_name => survey.name
    redirect_to surveys_path
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
    users = Sanitizer.clean_params(params[:survey][:user_ids])
    organizations = Sanitizer.clean_params(params[:survey][:participating_organization_ids])
    if users.blank? && organizations.blank?
      flash[:error] = t "flash.users_and_organizations_blank"
      redirect_to(:back)
    end
  end
end
