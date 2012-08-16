class SurveysController < ApplicationController

  def new
   @survey = Survey.new 
  end
end
