module Api
  module V1
    class ResponsesController < ApplicationController
      def create
        response = Response.new(params[:response])
        response.survey_id = params[:survey_id]
        response.save
        render :json => response.to_json
      end
    end
  end
end
