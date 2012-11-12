class SessionsController < ApplicationController

  def create
    auth = request.env["omniauth.auth"]
    session[:user_id] = auth['uid']
    session[:user_info] = auth['info']
    session[:access_token] = auth['credentials']['token']
    session[:session_token] = nil
    redirect_to request.env['omniauth.origin'] || root_path
  end

  def destroy
    reset_session
    redirect_to(root_path)
  end

  def failure
    redirect_to root_path, :notice => "You are not authorized to use this application"
  end
end
