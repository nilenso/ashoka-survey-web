module Api
  module V1
    class APIApplicationController < ApplicationController

      private

      def current_user_info
        if params[:access_token].blank?
          super
        else
          raw_info = access_token(params[:access_token]).get('api/me').parsed
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

      def access_token(token_string)
        OAuth2::AccessToken.new(oauth_client, token_string)
      end
    end
  end
end
