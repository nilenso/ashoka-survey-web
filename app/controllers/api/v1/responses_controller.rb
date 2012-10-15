module Api
  module V1
    class ResponsesController < ApplicationController
      def create
        response = Response.save_with_answers(params[:response], params[:survey_id])
        if response.valid?
          render :json => response.to_json
        else
          render :nothing => true, :status => :bad_request
        end
      end

      def update
        response = Response.find(params[:id])
        if response.update_attributes(params[:response])
          render :json => response.to_json
        else
          render :nothing => true, :status => :bad_request
        end
      end
    end
  end
end