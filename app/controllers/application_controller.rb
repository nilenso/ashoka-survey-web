class ApplicationController < ActionController::Base
  protect_from_forgery
    before_filter :set_locale

  def default_url_options(options={})
    return { :locale => I18n.locale } unless I18n.locale == I18n.default_locale
    return { :locale => nil }
  end

  rescue_from OAuth2::Error do |exception|
    if exception.response.status == 401
      session[:user_id] = nil
      session[:access_token] = nil
      redirect_to root_url, alert: "Access token expired, try signing in again."
    end
  end

  private

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  def oauth_client
    @oauth_client ||= OAuth2::Client.new(ENV["OAUTH_ID"], ENV["OAUTH_SECRET"], ENV["OAUTH_SERVER_URL"])
  end

  def access_token
    if session[:access_token]
      @access_token ||= OAuth2::AccessToken.new(oauth_client, session[:access_token])
    end
  end
end
