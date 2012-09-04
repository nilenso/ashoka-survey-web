module Api
  module V1
    class QuestionsController < ApplicationController

      def create
        question = Question.new(params[:question])
        if question.save
          render :json => question
        else
          render :json => question.errors.full_messages, :status => :bad_request
        end
      end

      def update
        question = Question.find(params[:id])
        if question.update_attributes(params[:question])
          render :json => question
        else
          render :json => question.errors.full_messages, :status => :bad_request
        end
      end

      def image_upload
        question = Question.find(params[:id])
        question.image = File.open(params[:image].path)
        question.save
        render :nothing => true
      end
    end
  end
end
