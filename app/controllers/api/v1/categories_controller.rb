
module Api
  module V1
    class CategoriesController < APIApplicationController
      before_filter :dont_cache
      authorize_resource

      def create
        category = Category.new_category_by_type(params[:category][:type], params[:category])
        if category.save
          render :json => category.to_json
        else
          render :json => category.errors.full_messages, :status => :bad_request
        end
      end

      def update
        category = Category.find_by_id(params[:id])
        if category && category.update_attributes(params[:category])
          render :json => category.to_json
        else
          render :json => category ? category.errors.full_messages : :nothing, :status => :bad_request
        end
      end

      def destroy
        category = Category.find_by_id(params[:id])
        if category
          Category.destroy(params[:id])
          render :nothing => true
        else
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
          render :json => category.to_json_with_sub_elements
        else
          render :nothing => true, :status => :bad_request
        end
      end

      def duplicate
        category = Category.find_by_id(params[:id])
        if category && category.copy_with_order
          flash[:notice] = t("flash.category_duplicated")
        else
          flash[:error] = t("flash.category_duplication_failed")
        end
        redirect_to :back
      end

      private
      def dont_cache
        expires_now
      end
    end
  end
end
