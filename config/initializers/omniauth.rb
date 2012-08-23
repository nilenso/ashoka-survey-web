require File.expand_path('lib/omniauth/strategies/user_owner', Rails.root)

Rails.application.config.middleware.use OmniAuth::Builder do
    provider :user_owner, ENV["OAUTH_ID"], ENV["OAUTH_SECRET"]
end
