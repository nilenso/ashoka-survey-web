module Api
  module V1
    class APIApplicationController < ApplicationController

      rescue_from OAuth2::Error do |exception|
        if exception.response.status == 401
          render :nothing => true, :status => :unauthorized
        end
      end

      rescue_from CanCan::AccessDenied do |exception|
        render :nothing => true, :status => :unauthorized
      end


      private

      def current_user_info
        if params[:access_token].blank? && user_currently_logged_in?
          # Survey builder
          super
        else
          # Mobile
          raw_info = OAuth2::AccessToken.new(oauth_client, params[:access_token]).get('api/me').parsed
          user_info = {
            :name => raw_info['name'],
            :email => raw_info['email'],
            :role => raw_info['role'],
            :user_id => raw_info['id'],
            :org_id => raw_info['organization_id'],
            :org_type => raw_info["organization"]["org_type"]
          }
          user_info
        end
      end
    end
  end
end
