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

    user_ids = params[:survey][:user_ids].reject { |user_id| user_id.blank? }
    user_ids.each { |user_id| SurveyUser.create(:survey_id => survey.id, :user_id => user_id)}

    organization_ids = params[:survey][:participating_organization_ids].reject { |org_id| org_id.blank? }
    organization_ids.each { |org_id| ParticipatingOrganization.create(:survey_id => survey.id, :organization_id => org_id) }

    redirect_to surveys_path, :notice => "Survey has been shared"
  end
end
