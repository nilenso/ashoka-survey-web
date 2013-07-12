class ResponsesDashboardController < ApplicationController
  def show
    @survey = Survey.find(params[:survey_id])
    @current_user_id = current_user
  end
end
