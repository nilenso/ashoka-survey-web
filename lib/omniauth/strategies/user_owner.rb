module OmniAuth
  module Strategies
    class UserOwner < OmniAuth::Strategies::OAuth2
      option :name, :user_owner

      option :client_options, {
        site: ENV["OAUTH_SERVER_URL"],
        authorize_path: "/oauth/authorize"
      }

      uid do
        raw_info["id"]
      end

      info do
        {
          :name => raw_info["name"],
          :email => raw_info["email"],
          :role => raw_info["role"],
          :org_id => raw_info["organization_id"],
          :org_type => raw_info["organization"].try(:[], "org_type"),
          :org_name => raw_info["organization"].try(:[], "name")
        }
      end

      def raw_info
        @raw_info ||= access_token.get('/api/me').parsed
      end
    end
  end
end
