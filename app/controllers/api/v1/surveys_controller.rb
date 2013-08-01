module Api
  module V1
    class SurveysController < APIApplicationController
      authorize_resource :except => [:identifier_questions, :questions_count]

      after_filter :only => [:update] { send_to_mixpanel("Survey edited", {:survey => @survey.name}) if @survey.present? }
      after_filter :only => [:duplicate] { send_to_mixpanel("Survey duplicated", {:survey => @survey.name}) if @survey.present? }

      def questions_count
        surveys = Survey.accessible_by(current_ability).active_plus(extra_survey_ids)
        render :json => { count: surveys.with_questions.count }
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
          survey_json = survey.decorate(:context => {:access_token => access_token}).as_json
          survey_json['elements'] = survey.elements_in_order_as_json
          render :json => survey_json
        else
          render :nothing => true, :status => :bad_request
        end
      end

      def update
        sleep 5
        @survey = Survey.find_by_id(params[:id])
        if @survey && @survey.update_attributes(params[:survey])
          render :json => @survey.to_json
        else
          # TODO: Remove `full_messages` when the old survey builder is deprecated
          response = { :full_errors => @survey.try(:errors).try(:full_messages), :errors =>  @survey.try(:errors).try(:messages) }
          render :json => response, :status => :bad_request
        end
      end

      def duplicate
        @survey = Survey.find(params[:id])
        job = @survey.delay(:queue => 'survey_duplication').duplicate(:organization_id => current_user_org)
        render :json => { :job_id => job.id }
      end

      private

      def extra_survey_ids
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
