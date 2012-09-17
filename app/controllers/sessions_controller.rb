class SessionsController < ApplicationController

  def create
    auth = request.env["omniauth.auth"]
    session[:user_id] = auth['uid']
    session[:user_info] = auth['info']
    Organization.sync(auth['info']['organizations'])
    session[:access_token] = auth['credentials']['token']
    redirect_to request.env['omniauth.origin'] || root_path
  end

  def destroy
    session[:user_id] = nil
    session[:user_info] = nil
    session[:access_token] = nil
    redirect_to(root_path)
  end

  def failure
    redirect_to root_path, :notice => "You are not authorized to use this application"
  end
end
