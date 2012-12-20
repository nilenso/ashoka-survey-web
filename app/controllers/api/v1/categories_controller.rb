
module Api
  module V1
    class CategoriesController < APIApplicationController
      #before_filter :dont_cache
      #authorize_resource

      def create
        category = Category.new(params[:category])
        if category.save
          render :json => category.to_json
        else
          p category.errors
          render :json => category.errors.full_messages, :status => :bad_request
        end
      end

      def update
        category = Category.find(params[:id])
        if category.update_attributes(params[:category])
          render :json => category.to_json
        else
          render :json => category.errors.full_messages, :status => :bad_request
        end
      end

      def destroy
        begin
          Category.destroy(params[:id])
          render :nothing => true
        rescue ActiveRecord::RecordNotFound
          render :nothing => true, :status => :bad_request
        end
      end

      def index
        survey = Survey.find_by_id(params[:survey_id])
        if survey
          render :json => survey.first_level_categories
        else
          render :nothing => true, :status => :bad_request
        end
      end

      def show
        category = Category.find_by_id(params[:id])
        if category
          render :json => category.to_json
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
