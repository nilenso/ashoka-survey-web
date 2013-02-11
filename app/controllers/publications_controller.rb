class PublicationsController < ApplicationController
  before_filter :require_finalized_survey

  def edit
    @survey = Survey.find(params[:survey_id])
    authorize! :edit_publication, @survey
    field_agents = @survey.users_for_organization(access_token, current_user_org)
    @published_users = field_agents[:published]
    @unpublished_users = field_agents[:unpublished]

    partitioned_organizations = @survey.partitioned_organizations(access_token)
    @shared_organizations = partitioned_organizations[:participating]
    @unshared_organizations = partitioned_organizations[:not_participating]
  end

  def update
    survey = Survey.find(params[:survey_id])
    authorize! :update_publication, survey
    publisher = Publisher.new(survey, access_token, params[:survey])
    if publisher.publish
      flash[:notice] = t "flash.survey_published", :survey_name => survey.name
      redirect_to surveys_path
    else
      flash[:error] = publisher.errors.full_messages.join(', ')
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
end
