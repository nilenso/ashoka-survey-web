module Api
  module V1
    class ResponsesController < APIApplicationController
      authorize_resource

      def create
        response = Response.new
        response.user_id = params[:user_id]
        response.organization_id = params[:organization_id]
        answers_attributes = params[:response].delete(:answers_attributes)
        response.update_attributes(params[:response]) # Response isn't created before the answers, so we need to create the answers after this.
        response.validating if params[:response][:status] == "complete"
        response.update_attributes({:answers_attributes => answers_attributes}) if response.save

        if response.incomplete? && response.valid?
          render :json => response.to_json_with_answers_and_choices
        elsif response.validating? && response.valid?
          response.complete
          render :json => response.to_json_with_answers_and_choices 
        else
          response_json = response.to_json_with_answers_and_choices
          response.destroy
          render :json => response_json, :status => :bad_request
        end
      end

      def update
        response = Response.find_by_id(params[:id])
        return render :nothing => true, :status => :gone if response.nil?
        response.user_id = response.organization_id = 0 # temporary fix for no login on mobile
        answers_attributes = params[:response].delete(:answers_attributes)
        response.merge_status(params[:response])
        response.validating if response.complete?
        answers_to_update = response.select_new_answers(answers_attributes)
        response.update_attributes({ :answers_attributes => answers_to_update }) if response.save        
        if response.incomplete? && response.valid?
          render :json => response.to_json_with_answers_and_choices
        elsif response.validating? && response.valid?
          response.complete
          render :json => response.to_json_with_answers_and_choices
        else
          response_json = response.to_json_with_answers_and_choices
          render :json => response_json, :status => :bad_request
        end
      end

      def image_upload
        answer = Answer.find_by_id(params[:answer_id])
        answer.select_latest_image(params) if answer
        if answer && answer.save
          render :json => { :image_url => answer.thumb_url, :photo_updated_at => answer.photo_updated_at }
        else
          render :nothing => true, :status => :bad_request
        end
      end
    end
  end
end
