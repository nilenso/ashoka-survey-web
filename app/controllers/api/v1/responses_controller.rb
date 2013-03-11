module Api::V1
  class ResponsesController < APIApplicationController
    load_resource :survey, :only => [:index, :show, :count]
    load_resource :through => :survey, :only => [:index, :show, :count]
    authorize_resource

    before_filter :decode_base64_images, :convert_to_datetime, :only => [:create, :update]
    before_filter :require_response_to_not_exist, :only => :create

    def index
      render :json => @responses.paginate(:page => params[:page],
                                          :per_page => Response.page_size(params[:page_size]
                                          )).as_json(:methods => :answers_for_identifier_questions)
    end

    def count
      render :json => { count: @responses.count }
    end

    def create
      response = Response.new
      response.user_id = params[:user_id]
      response.organization_id = params[:organization_id]
      response.update_attributes(params[:response].except(:answers_attributes)) # Response isn't created before the answers, so we need to create the answers after this.
      response.validating if params[:response][:status] == "complete"
      response.update_attributes({:answers_attributes => params[:response][:answers_attributes]}) if response.valid?
      response.update_records
      if response.invalid?
        render :json => response.render_json, :status => :bad_request
        destroy_response(response)
        Airbrake.notify(ActiveRecord::RecordInvalid.new(response))
      else
        render :json => response.render_json
      end
    end

    def update
      response = Response.find_by_id(params[:id])
      return render :nothing => true, :status => :gone if response.nil?
      response.merge_status(params[:response].except(:answers_attributes))
      response.validating if response.complete?
      answers_to_update = response.select_new_answers(params[:response][:answers_attributes])
      response.update_attributes({ :answers_attributes => answers_to_update })
      response.update_records

      if response.invalid?
        response.incomplete
        render :json => response.render_json, :status => :bad_request
        Airbrake.notify(ActiveRecord::RecordInvalid.new(response))
      else
        render :json => response.render_json
      end
    end

    def show
      response = Response.find_by_id(params[:id])
      render :json => response.as_json(:include => { :answers => { :include => { :question => { :include => [:category, :options] }} }}) 
    end

    private

    def destroy_response(response)
      Response.find(response).destroy if response.persisted?
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
