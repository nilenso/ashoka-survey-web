class QuestionsController < ApplicationController
  def create
    question = Question.create(:content => "untitled question",
                               :type => params[:type],
                               :survey_id => params[:survey_id])
    render :json => question
  end
end
