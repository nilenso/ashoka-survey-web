module Api
  module V1
    class AuthController < APIApplicationController
      def create
        client = OAuth2::Client.new(ENV["OAUTH_ID"], ENV["OAUTH_SECRET"], :site => ENV["OAUTH_SERVER_URL"])
        access_token = client.password.get_token(params['username'], params['password'])
        username = access_token.get('api/me').parsed['name']
        user_id = access_token.get('api/me').parsed['id']
        render :json => { :access_token => access_token.token, :username => username, :user_id => user_id }
      end
    end
  end
end
