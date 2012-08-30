module Api
  module V1
    class QuestionsController < ApplicationController
      def create
        question = Question.create(params[:question])
        render :json => question
      end
      def update
        question = Question.find(params[:id])
        question.content = params[:content]
        question.mandatory = params[:mandatory]
        question.max_length = params[:max_length]
        question.type = params[:type]
        if question.save
        	flash[:notice] = "Questions have been added to the survey"
        	redirect_to root_path
        else
        	flash[:error] = "Sorry, we could not add the questions"
        	render :json => question
        end
      end
    end
  end
end
