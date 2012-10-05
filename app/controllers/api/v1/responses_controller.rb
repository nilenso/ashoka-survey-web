module Api
  module V1
    class ResponsesController < ApplicationController
      def create
        response = Response.new(params[:response])
        response.survey_id = params[:survey_id]
        response.organization_id = 0 #Temporary fix for no user logged in on mobile side 
        response.user_id = 0 #Temporary fix for no user logged in on mobile side 
        if response.save
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