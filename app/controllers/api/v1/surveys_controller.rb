module Api
  module V1
    class SurveysController < APIApplicationController
      caches_action :show, :if => :survey_finalized?
      authorize_resource :except => [:identifier_questions, :questions_count]
      before_filter :only_finalized_and_unexpired_surveys, :only => [:index, :questions_count]

      def index
        @surveys ||= Survey.accessible_by(current_ability)
        render :json => @surveys
      end

      def questions_count
        @surveys ||= Survey.accessible_by(current_ability)
        render :json => { count: @surveys.with_questions.count }
      end
      
      def identifier_questions
        survey = Survey.find_by_id(params[:id])
        authorize! :read, survey
        if survey
          render :json => survey.identifier_questions
        else
          render :nothing => true, :status => :bad_request
        end 
      end

      def show
        survey = Survey.find_by_id(params[:id])
        authorize! :read, survey
        if survey
          survey_json = survey.as_json
          survey_json['elements'] = survey.elements_in_order_as_json
          render :json => survey_json
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
        @surveys = Survey.accessible_by(current_ability)
        survey = Survey.arel_table
        @surveys = @surveys.where(
          (
            survey[:expiry_date].gt(Date.today). # Not expired
            and(survey[:finalized].eq(true)).     # Finalized
            and(survey[:archived].eq(false))
          ).
          or(survey[:id].in(extra_surveys))
        )
      end

      def extra_surveys
        extra_survey_ids = params[:extra_surveys] || ""
        extra_survey_ids.split(',').map(&:to_i)
      end

      def survey_finalized?
        survey = Survey.find_by_id(params[:id])
        survey.finalized?
      end
    end
  end
end
