module Api
  module V1
    class ResponsesController < ApplicationController
      def create
        response = Response.new
        response.user_id = response.organization_id = 0 # temporary fix for no login on mobile
        answers_attributes = params[:response].delete(:answers_attributes)
        response.update_attributes(params[:response]) # Response isn't created before the answers, so we need to create the answers after this.
        response.validating if params[:response][:status] == "complete"
        response.update_attributes({:answers_attributes => answers_attributes}) if response.save

        if response.incomplete? && response.valid?
          render :json => response.to_json_with_answers_and_choices
        elsif response.validating? && response.valid?
          response.complete
          render :nothing => true
        else
          response_json = response.to_json_with_answers_and_choices
          response.destroy
          render :json => response_json, :status => :bad_request
        end
      end

      def update
        response = Response.find(params[:id])
        response.user_id = response.organization_id = 0 # temporary fix for no login on mobile
        answers_attributes = params[:response].delete(:answers_attributes)
        response.update_attributes(params[:response]) # Response isn't saved before the answers, so we need to create the answers after this.
        response.validating if params[:response][:status] == "complete"
        answers_to_update = response.select_new_answers(answers_attributes)
        response.update_attributes({ :answers_attributes => answers_to_update }) if response.save        
        if response.incomplete? && response.valid?
          render :json => response.to_json_with_answers_and_choices
        elsif response.validating? && response.valid?
          response.complete
          render :nothing => true
        else
          response_json = response.to_json_with_answers_and_choices
          response.destroy
          render :json => response_json, :status => :bad_request
        end
      end
    end
  end
end
