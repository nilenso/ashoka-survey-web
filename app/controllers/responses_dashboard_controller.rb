class ResponsesDashboardController < ApplicationController
  def index
    @survey = Survey.find(params[:survey_id])
    authorize! :view_survey_dashboard, @survey
    @ids_for_users_with_responses = @survey.ids_for_users_with_responses
  end

  def show
    @survey = Survey.find(params[:survey_id])
    authorize! :view_survey_dashboard, @survey
    @user_id = params[:id].to_i
  end
end
