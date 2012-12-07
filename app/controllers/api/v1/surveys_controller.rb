module Api
  module V1
    class SurveysController < APIApplicationController
      load_resource :only => :index
      before_filter :only_finalized_and_unexpired_surveys, :only => :index
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

      def only_finalized_and_unexpired_surveys
        @surveys = @surveys.finalized.not_expired | extra_surveys
      end

      def extra_surveys
        extra_survey_ids = params[:extra_surveys] || ""
        @surveys.finalized.where('id in (?)', extra_survey_ids.split(',').map(&:to_i))
      end
    end
  end
end
