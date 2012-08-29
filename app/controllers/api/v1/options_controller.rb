module Api
  module V1
    class OptionsController < ApplicationController
      def create
        option = Option.create(params[:option])
        render :json => option
      end
    end
  end
end
