class SurveysController < ApplicationController

  def index
    @surveys = Survey.all
  end
  
  def new
    @survey = Survey.new
  end

  def create
    @survey = Survey.new(params[:survey])

    if @survey.save
      redirect_to root_path
      flash[:notice] = "Survey successfully created"
    else
      render :new
    end
  end
end
