class SurveyShareController < ApplicationController

  def edit
    @survey = Survey.find_by_id(params[:survey_id])
    authorize! :share, @survey

    if @survey.published?
      @users = access_token.get('/api/organization_users').parsed
      @other_organizations = Organization.all_except(access_token, @survey.organization_id)
    else
      redirect_to surveys_path
      flash[:error] = "Can not share an unpublished survey"
    end
  end

  def update
    survey = Survey.find_by_id(params[:survey_id])
    authorize! :share, survey

    survey.participating_organizations.destroy_all
    survey.survey_users.destroy_all

    users = Sanitizer.clean_params(params[:survey][:user_ids])
    survey.share_with_users(users)

    organizations = Sanitizer.clean_params(params[:survey][:participating_organization_ids])
    survey.share_with_organizations(organizations)
    redirect_to surveys_path, :notice => "Survey has been shared"
  end
end
