class PublicationsController < ApplicationController
  before_filter :require_finalized_survey

  after_filter :only => [:destroy] { send_to_mixpanel("Survey unpublished", { :survey => @survey.name}) if @survey.present? }

  def edit
    @survey = Survey.find(params[:survey_id]).decorate
    authorize! :edit_publication, @survey
    publishable_users = @survey.users_for_organization(access_token, current_user_org)
    @published_users = publishable_users[:published]
    @unpublished_users = publishable_users[:unpublished]

    partitioned_organizations = @survey.partitioned_organizations(access_token)
    @shared_organizations = partitioned_organizations[:participating]
    @unshared_organizations = partitioned_organizations[:not_participating]
  end

  def update
    survey = Survey.find(params[:survey_id])
    authorize! :update_publication, survey
    publisher = Publisher.new(survey, access_token, params[:survey])
    if publisher.publish(:organization_id => current_user_org)
      flash[:notice] = t "flash.survey_published", :survey_name => survey.name
      send_to_mixpanel("Survey published", { :survey => survey.name })
      redirect_to surveys_path
    else
      flash[:error] = publisher.errors.full_messages.join(', ')
      redirect_to(:back)
    end
  end

  def unpublish
    @survey = Survey.find(params[:survey_id])
    authorize! :edit_publication, @survey
    if @survey.published?
      field_agents = @survey.users_for_organization(access_token, current_user_org)
      @published_users = field_agents[:published]
      @unpublished_users = field_agents[:unpublished]
    else
      redirect_to surveys_path
      flash[:error] = t "flash.unpublish_draft_survey"
    end
  end

  def destroy
    @survey = Survey.find(params[:survey_id])
    authorize! :update_publication, @survey
    publisher = Publisher.new(@survey, access_token, params[:survey])
    publisher.unpublish_users
    redirect_to surveys_path
    flash[:notice] = "Unpublished users successfully"
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
