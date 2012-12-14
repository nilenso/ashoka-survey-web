
module Api
  module V1
    class QuestionsController < APIApplicationController
      before_filter :dont_cache
      authorize_resource

      def create
        question = Question.new_question_by_type(params[:question][:type], params[:question])
        if question.save
          render :json => question.to_json(:methods => :type)
        else
          render :json => question.errors.full_messages, :status => :bad_request
        end
      end

      def update
        question = Question.find(params[:id])
        if question.update_attributes(params[:question])
          render :json => question.to_json(:methods => :type)
        else
          render :json => question.errors.full_messages, :status => :bad_request
        end
      end

      def destroy
        begin
          Question.destroy(params[:id])
          render :nothing => true
        rescue ActiveRecord::RecordNotFound
          render :nothing => true, :status => :bad_request
        end
      end

      def image_upload
        question = Question.find(params[:id])
        question.image = File.open(params[:image].path)
        question.save
        render :json => { :image_url => question.image.url(:thumb) }
      end

      def index
        survey = Survey.find_by_id(params[:survey_id])
        if survey
          render :json => survey.first_level_questions.to_json(:methods => [:type, :image_url, :image_in_base64])
        else
          render :nothing => true, :status => :bad_request
        end
      end

      def show
        question = Question.find_by_id(params[:id])
        if question
          render :json => question.to_json(:methods => [:type, :image_url, :image_in_base64])
        else
          render :nothing => true, :status => :bad_request
        end
      end

      private
      def dont_cache
        expires_now
      end
    end
  end
end
