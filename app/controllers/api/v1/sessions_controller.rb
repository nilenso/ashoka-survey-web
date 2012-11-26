module Api
  module V1
    class SessionsController < ApplicationController
      def create
        client = OAuth2::Client.new(ENV["OAUTH_ID"], ENV["OAUTH_SECRET"], :site => ENV["OAUTH_SERVER_URL"])
        access_token = client.password.get_token(params['username'], params['password'])

        auth = access_token.get('api/me').parsed
        session[:user_id] = auth['id']
        session[:user_info] = { name: auth['name'], email: auth['email'], role: auth['role'], org_id: auth['organization_id'] }
        session[:access_token] = access_token.token

        render :json => session.select { |key,_| [:user_id, :user_info].include? key.to_sym }
      end

      def destroy
        reset_session
        render :nothing => true
      end
    end
  end
end
