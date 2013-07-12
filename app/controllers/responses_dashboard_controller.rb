class ResponsesDashboardController < ApplicationController
  def index
    @survey = Survey.find(params[:survey_id])
    @ids_for_users_with_responses = @survey.ids_for_users_with_responses
  end

  def show
    @survey = Survey.find(params[:survey_id])
    @current_user_id = current_user
  end
end
