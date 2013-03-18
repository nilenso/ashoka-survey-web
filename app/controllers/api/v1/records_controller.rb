module Api
  module V1
    class RecordsController < APIApplicationController
      respond_to :json

      def create
        record = Record.create(params[:record])
        # TODO: Authorize!
        if record.valid?
          render :json => record
        else
          render :json => record.errors, :status => :bad_request
        end
      end

      def update
        record = Record.find_by_id(params[:id])
        if record.nil?
          render :nothing => true, :status => :gone
        else
          render :json => record
        end
      end

      def ids_for_response
        response = Response.find(params[:response_id])
        authorize! :read, response
        category = MultiRecordCategory.find(params[:category_id])
        render :json => category.records_for_response(params[:response_id]).map(&:id)
      end
    end
  end
end
