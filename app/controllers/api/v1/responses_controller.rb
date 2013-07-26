module Api::V1
  class ResponsesController < APIApplicationController
    load_resource :survey, :only => [:index, :show, :count]
    load_resource :through => :survey, :only => [:show, :count]
    authorize_resource

    before_filter :decode_base64_images, :convert_to_datetime, :only => [:create, :update]
    before_filter :require_response_to_not_exist, :only => :create

    def count
      render :json => { count: @responses.count }
    end

    def create
      response = Response.new
      if response.create_response(params[:response])
        render :json => response.to_json_with_answers_and_choices
      else
        render :json => response.to_json_with_answers_and_choices, :status => :bad_request
        Airbrake.notify(ActiveRecord::RecordInvalid.new(response))
      end
    end

    def update
      response = Response.find_by_id(params[:id])
      return render :nothing => true, :status => :gone if response.nil?
      response.update_response_with_conflict_resolution(params[:response])
      response.update_records # TODO: Refactor this into the model method, if possible

      if response.invalid?
        render :json => response.to_json_with_answers_and_choices, :status => :bad_request
        Airbrake.notify(ActiveRecord::RecordInvalid.new(response))
      else
        render :json => response.to_json_with_answers_and_choices
      end
    end

    def show
      response = Response.find_by_id(params[:id])
      render :json => response.as_json(:include => :answers)
    end

    private

    def decode_base64_images
      answers_attributes = params[:response][:answers_attributes] || []
      answers_attributes.each do |_, answer|
        if answer.has_key? 'photo'
          sio = StringIO.new(Base64.decode64(answer['photo']))
          sio.class.class_eval { attr_accessor :content_type, :original_filename } # Need to do this to pass Paperclip's content_type validation. Found this at http://stackoverflow.com/questions/5054982/rails3-problem-saving-base64-image-with-paperclip
          sio.content_type = 'image/jpeg'
          sio.original_filename = "photo_#{SecureRandom.hex}.jpeg"
          answer['photo'] = sio
        end
      end
    end

    def convert_to_datetime
      answers_attributes = params[:response][:answers_attributes]
      answers_attributes.each do |key, answer_attributes|
        answer_attributes["updated_at"] = Time.at(answer_attributes["updated_at"].to_i).to_s
      end unless answers_attributes.blank?
      params[:response][:updated_at] = Time.at(params[:response][:updated_at].to_i).to_s unless params[:response].nil?
    end

    def require_response_to_not_exist
      if params[:mobile_id]
        response = Response.find_by_mobile_id(params[:mobile_id])
        if response
          render :json => response.to_json_with_answers_and_choices
        end
      end
    end
  end
end
