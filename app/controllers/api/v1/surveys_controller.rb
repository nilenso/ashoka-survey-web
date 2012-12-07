module Api
  module V1
    class SurveysController < APIApplicationController
      before_filter :only_published_and_unexpired_surveys, :only => :index
      load_resource :only => :index
      authorize_resource

      def index
        @surveys ||= []        
        render :json => @surveys
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

      private

      def only_published_and_unexpired_surveys
        @surveys = Survey.published.not_expired
      end
    end
  end
end
