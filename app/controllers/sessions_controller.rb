class SessionsController < ApplicationController

  def create
    auth = request.env["omniauth.auth"]
    session[:user_id] = auth['uid']
    session[:access_token] = auth['credentials']['token']
    redirect_to root_path
  end

  def destroy
    session[:user_id] = nil
    session[:access_token] = nil
    redirect_to(root_path)
  end
end
