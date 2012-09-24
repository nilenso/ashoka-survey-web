module Api
  module V1
    class OptionsController < ApplicationController
      def create
        option = Option.new(params[:option])
        if option.save
          render :json => option
        else
          render :json => option.errors.full_messages, :status => :bad_request
        end
      end

      def update
        option = Option.find(params[:id])
        if option.update_attributes(params[:option])
          render :json => option
        else
          render :json => option.errors.full_messages, :status => :bad_request
        end
      end

      def destroy
        begin
          Option.destroy(params[:id])
          render :nothing => true
        rescue ActiveRecord::RecordNotFound
          render :nothing => true, :status => :bad_request
        end
      end

      def index
        question = Question.find_by_id(params[:question_id])
        if question
          render :json => question.options.select('id')
        else
          render :nothing => true, :status => :bad_request
        end
      end
    end
  end
end
