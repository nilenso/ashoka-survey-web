module Api
  module V1
    class SurveysController < ApplicationController
      load_resource :only => :index
      authorize_resource

      def index
        render :json => Survey.select("id, name, description, expiry_date")
      end

      def show
        survey = Survey.find_by_id(params[:id])
        if survey
          render :json => survey.to_json
        else
          render :nothing => true, :status => :bad_request
        end
      end

      def update
        survey = Survey.find_by_id(params[:id])
        if survey && survey.update_attributes(params[:survey])
          render :json => survey.to_json
        else
          render :json => survey.try(:errors).try(:full_messages), :status => :bad_request
        end
      end
    end
  end
end
