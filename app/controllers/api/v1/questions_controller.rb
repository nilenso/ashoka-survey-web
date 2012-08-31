module Api
  module V1
    class QuestionsController < ApplicationController

      def create
        question = Question.create(params[:question])
        render :json => question
      end

      def update
        question = Question.find(params[:id])
        question.update_attributes(params[:question])
        render :json => question
      end
    end
  end
end
