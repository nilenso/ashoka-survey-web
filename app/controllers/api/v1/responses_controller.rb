module Api
  module V1
    class ResponsesController < ApplicationController
      def create
        response = Response.new
        response.user_id = response.organization_id = 0 # temporary fix for no login on mobile
        answers_attributes = params[:response].delete(:answers_attributes)        
        response.update_attributes(params[:response]) # Response isn't created before the answers, so we need to create the answers after this.
        response.update_attributes({:answers_attributes => answers_attributes}) if response.save
        response.validating
        if response.valid?
          render :json => response.to_json
          response.complete
        else
          response.incomplete
          render :nothing => true, :status => :bad_request
        end
      end

      def update
        response = Response.find(params[:id])
        response.validating
        if response.update_attributes(params[:response])
          response.complete
          render :json => response.to_json
        else
          response.complete
          render :nothing => true, :status => :bad_request
        end
      end
    end
  end
end
