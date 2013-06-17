module Api
  module V1
    class OptionsController < APIApplicationController
      before_filter :dont_cache

      def create
        option = Option.new(params[:option])
        authorize! :update, option.try(:survey)
        if option.save
          render :json => option
        else
          render :json => option.errors.full_messages, :status => :bad_request
        end
      end

      def update
        option = Option.find(params[:id])
        authorize! :update, option.try(:survey)
        if option.update_attributes(params[:option])
          render :json => option
        else
          render :json => option.errors.full_messages, :status => :bad_request
        end
      end

      def destroy
        option = Option.find_by_id(params[:id])
        authorize! :update, option.try(:survey)
        begin
          Option.destroy(params[:id])
          render :nothing => true
        rescue ActiveRecord::RecordNotFound
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
