module Api
  module V1
    class OptionsController < ApplicationController
      def create
        option = Option.new(params[:option])
        if option.save
          render :json => option
        else
          render :json => option.errors.full_messages, :status => :bad_request
        end
      end

      def update
        option = Option.find(params[:id])
        if option.update_attributes(params[:option])
          render :json => option
        else
          render :json => option.errors.full_messages, :status => :bad_request
        end
      end
    end
  end
end
