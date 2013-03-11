class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :authorize_profiler, :set_locale, :session_token
  helper_method :current_user_info, :register_path, :new_user_path, :current_ability

  def default_url_options(options={})
    return { :locale => I18n.locale } unless I18n.locale == I18n.default_locale
    return { :locale => nil }
  end

  def server_url
    request.protocol + request.host_with_port
  end

  rescue_from OAuth2::Error do |exception|
    if exception.response.status == 401
      session[:user_id] = nil
      session[:access_token] = nil
      redirect_to root_url, alert: t(:login_again)
    end
  end

  rescue_from CanCan::AccessDenied do |exception|
    logger.debug "Can can access denied. Exception: #{exception.inspect}"
    error_message = exception.message
    error_message += " " + t("flash.denied_access", :action => exception.action, :subject => exception.subject)
    flash[:error] = error_message
    redirect_to root_url
  end

  def current_ability
    if params[:controller] == 'responses'
      @current_ability ||= PublicResponseAbility.new(current_user_info)
    else
      @current_ability ||= Ability.ability_for(current_user_info)
    end
  end

  def user_currently_logged_in?
    session[:user_id].present?
  end

  def current_user
    session[:user_id] if user_currently_logged_in?
  end

  def current_user_info
    if user_currently_logged_in?
      session[:user_info].merge(:user_id => session[:user_id], :session_token => session_token)
    else
      { :session_token => session_token }
    end
  end

  def signed_in_as_cso_admin?
    session[:user_info][:role] == "cso_admin" if user_currently_logged_in?
  end

  def current_user_org
    session[:user_info][:org_id] if user_currently_logged_in?
  end

  def current_user_org_type
    session[:user_info][:org_type] if user_currently_logged_in?
  end

  def current_username
    current_user_info[:name]
  end

  def session_token
    session[:session_token] ||= SecureRandom.urlsafe_base64
  end

  helper_method :user_currently_logged_in?, :signed_in_as_cso_admin?, :current_user_org, :current_username

  def oauth_client
    @oauth_client ||= OAuth2::Client.new(ENV["OAUTH_ID"], ENV["OAUTH_SECRET"], :site => ENV["OAUTH_SERVER_URL"])
  end

  def access_token
    if session[:access_token]
      @access_token ||= OAuth2::AccessToken.new(oauth_client, session[:access_token])
    end
  end

  def register_path
    "#{ENV['OAUTH_SERVER_URL']}/register"
  end

  def new_user_path
    "#{ENV['OAUTH_SERVER_URL']}/organizations/#{current_user_org}/users/new"
  end

  private

  def authorize_profiler
    unless Rails.env.production?
      Rack::MiniProfiler.authorize_request
    end
  end

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

end
