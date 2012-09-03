module Api
  module V1
    class QuestionsController < ApplicationController

      def create
        question = Question.create(params[:question])
        render :json => question
      end

      def update
        question = Question.find(params[:id])
        if question.update_attributes(params[:question])
          render :json => question
        else
          render :json => question.errors, :status => :bad_request
        end
      end
    end
  end
end
