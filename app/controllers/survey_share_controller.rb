class SurveyShareController < ApplicationController

  def edit
    @survey = Survey.find_by_id(params[:survey_id])
    authorize! :share, @survey

    if @survey.published?
      users = Organization.users(access_token, current_user_org)
      @shared_users = @survey.users(access_token, current_user_org)
      @unshared_users = users.reject { |user| @shared_users.map(&:id).include?(user.id) }
      other_organizations = Organization.all_except(access_token, @survey.organization_id)
      @shared_organizations = @survey.organizations(access_token, current_user_org)
      @unshared_organizations = other_organizations.reject { |org| @shared_organizations.map(&:id).include?(org.id) }
    else
      redirect_to surveys_path
      flash[:error] = t "flash.sharing_unpublished_survey"
    end
  end

  def update
    survey = Survey.find_by_id(params[:survey_id])
    organizations = Sanitizer.clean_params(params[:survey][:participating_organization_ids])
    users = Sanitizer.clean_params(params[:survey][:user_ids])

    authorize! :share, survey

    survey.share_with_users(users)
    survey.share_with_organizations(organizations)

    redirect_to surveys_path, :notice => t("flash.survey_shared", :survey_name => survey.name)
  end
end
