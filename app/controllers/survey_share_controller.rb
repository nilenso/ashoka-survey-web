class SurveyShareController < ApplicationController

  def edit
    @survey = Survey.find_by_id(params[:survey_id])
    authorize! :share, @survey

    if @survey.published?
      @users = Organization.users(access_token, current_user_org)
      @other_organizations = Organization.all_except(access_token, @survey.organization_id)
    else
      redirect_to surveys_path
      flash[:error] = "Can not share an unpublished survey"
    end
  end

  def update
    survey = Survey.find_by_id(params[:survey_id])
    organizations = Sanitizer.clean_params(params[:survey][:participating_organization_ids])
    users = Sanitizer.clean_params(params[:survey][:user_ids])

    authorize! :share, survey

    survey.share_with_users(users, access_token)

    survey.share_with_organizations(organizations)
    redirect_to surveys_path, :notice => "Survey has been shared"
  end
end
