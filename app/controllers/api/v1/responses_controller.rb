module Api
  module V1
    class ResponsesController < ApplicationController
      def create
        response = Response.new
        response.user_id = response.organization_id = 0 # temporary fix for no login on mobile
        answers_attributes = params[:response].delete(:answers_attributes)        
        response.update_attributes(params[:response]) # Response isn't created before the answers, so we need to create the answers after this.
        response.update_attributes({:answers_attributes => answers_attributes}) if response.save
        if response.valid?
          render :json => response.to_json
        else
          p response.errors
          response.mark_incomplete
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
