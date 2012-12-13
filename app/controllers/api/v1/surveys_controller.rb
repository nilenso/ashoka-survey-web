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
        survey = Survey.arel_table
        @surveys = @surveys.where(
          (
            survey[:expiry_date].gt(Date.today). # Not expired
            and(survey[:finalized].eq(true))     # Finalized
          ).
          or(survey[:id].in(extra_surveys))
        )
      end

      def extra_surveys
        extra_survey_ids = params[:extra_surveys] || ""
        extra_survey_ids.split(',').map(&:to_i)
      end
    end
  end
end
