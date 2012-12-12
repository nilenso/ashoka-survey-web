module Api
  module V1
    class ResponsesController < APIApplicationController
      authorize_resource

      before_filter :decode_base64_images, :except => :image_upload

      def create
        response = Response.new
        response.user_id = params[:user_id]
        response.organization_id = params[:organization_id]
        answers_attributes = params[:response].delete(:answers_attributes)
        convert_to_datetime!(answers_attributes) unless answers_attributes.blank?
        updated_at_to_datetime!(params[:response]) unless params[:response].nil?
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
        answers_attributes = params[:response].delete(:answers_attributes)
        convert_to_datetime!(answers_attributes) unless answers_attributes.blank?
        updated_at_to_datetime!(params[:response]) unless params[:response].nil?
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
        updated_at_to_datetime!(params)
        answer.select_latest_image(params) if answer
        if answer && answer.save
          render :json => { :image_url => answer.thumb_url, :photo_updated_at => answer.photo_updated_at }
        else
          render :nothing => true, :status => :bad_request
        end
      end

      private

      def convert_to_datetime!(answers_attributes)
        answers_attributes.each do |key, answer_attributes|
          answer_attributes["updated_at"] = Time.at(answer_attributes["updated_at"].to_i).to_s
        end
      end

      def decode_base64_images
        answers_attributes = params[:response][:answers_attributes] || []
        answers_attributes.each do |_,answer|
          if answer.has_key? 'photo'
            sio = StringIO.new(Base64.decode64(answer['photo']))
            sio.class.class_eval { attr_accessor :content_type, :original_filename } # Need to do this to pass Paperclip's content_type validation. Found this at http://stackoverflow.com/questions/5054982/rails3-problem-saving-base64-image-with-paperclip  
            sio.content_type = 'image/jpeg'
            sio.original_filename = "photo_#{SecureRandom.hex}.jpeg"
            answer['photo'] = sio
          end
        end
      end

      def updated_at_to_datetime!(response_attr)
        response_attr['updated_at'] = Time.at(response_attr['updated_at'].to_i).to_s
      end

      def photo_updated_at_to_datetime!(response_attr)
        response_attr['photo_updated_at'] = Time.at(response_attr['photo_updated_at'].to_i).to_s
      end
    end
  end
end
