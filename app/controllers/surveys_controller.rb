class SurveysController < ApplicationController
  def new
   @survey = Survey.new 
  end

  def create
    @survey = Survey.new(params[:survey])
    redirect_to root_path
  end
end
